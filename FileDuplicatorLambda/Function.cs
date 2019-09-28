using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Amazon.Lambda.Core;
using Amazon.Lambda.S3Events;
using Amazon.S3;
using Amazon.S3.Util;
using Amazon;
using Amazon.S3.Model;
using System.Net;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace FileDuplicatorLambda
{
    public class Function
    {
        IAmazonS3 S3Client { get; set; }

        /// <summary>
        /// Default constructor. This constructor is used by Lambda to construct the instance. When invoked in a Lambda environment
        /// the AWS credentials will come from the IAM role associated with the function and the AWS region will be set to the
        /// region the Lambda function is executed in.
        /// </summary>
        public Function()
        {
            var regionName = Environment.GetEnvironmentVariable("REGION_NAME");
            if (string.IsNullOrWhiteSpace(regionName))
                throw new ArgumentNullException(nameof(regionName), "Region name cannot be null or empty");

            S3Client = new AmazonS3Client(new AmazonS3Config()
            {
                RegionEndpoint = RegionEndpoint.GetBySystemName(regionName)
            });
        }

        /// <summary>
        /// Constructs an instance with a preconfigured S3 client. This can be used for testing the outside of the Lambda environment.
        /// </summary>
        /// <param name="s3Client"></param>
        public Function(IAmazonS3 s3Client)
        {
            S3Client = s3Client ?? throw new ArgumentNullException(nameof(s3Client));
        }

        /// <summary>
        /// This method is called for every Lambda invocation. This method takes in an S3 event object and can be used 
        /// to respond to S3 notifications.
        /// </summary>
        /// <param name="evnt"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task<string> FunctionHandler(S3Event evnt, ILambdaContext context)
        {
            var s3Event = evnt.Records?[0].S3;
            if (s3Event == null)
            {
                return null;
            }

            context.Logger.LogLine("Received S3 event");

            try
            {
                var sourceBucketName = s3Event.Bucket.Name;
                var fileName = s3Event.Object.Key;
                var destinationBucketName = Environment.GetEnvironmentVariable("DESTINATION_BUCKET_NAME");

                if (string.IsNullOrWhiteSpace(destinationBucketName))
                    throw new ArgumentNullException(nameof(destinationBucketName), "The environment variable with destination S3 bucket name ('destination-bucket-name') is not set or empty.");

                if (sourceBucketName == destinationBucketName)
                {
                    var sameBucketsMessage = $"The source and destination S3 bucket names are the same. File '${fileName}' was not copied.";
                    context.Logger.LogLine(sameBucketsMessage);
                    return sameBucketsMessage;
                }

                var response = await S3Client.CopyObjectAsync(new CopyObjectRequest
                {
                    SourceBucket = sourceBucketName,
                    SourceKey = fileName,
                    DestinationBucket = destinationBucketName,
                    DestinationKey = fileName
                });

                if (IsSuccessfulStatus(response.HttpStatusCode))
                {
                    var successMessage = $"A file '${fileName}' successfully copied from bucket '${sourceBucketName}' to '${destinationBucketName}'.";
                    context.Logger.LogLine(successMessage);
                    return successMessage;
                }

                var failureMessage = $"Duplicator lambda returned not-success HTTP code (${(int)response?.HttpStatusCode}) while copying a file '${fileName}' from bucket '${sourceBucketName}' to '${destinationBucketName}'.";
                context.Logger.LogLine(failureMessage);
                return failureMessage;
            }
            catch (Exception e)
            {
                context.Logger.LogLine($"Error getting object {s3Event.Object.Key} from bucket {s3Event.Bucket.Name}. Make sure they exist and your bucket is in the same region as this function.");
                context.Logger.LogLine(e.Message);
                context.Logger.LogLine(e.StackTrace);
                throw;
            }
        }

        private bool IsSuccessfulStatus(HttpStatusCode code)
        {
            int codeValue = (int)code;
            return codeValue >= 200 && codeValue <= 299;
        }
    }
}
