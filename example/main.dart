// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_reddit_ads/otel_reddit_ads.dart';

/// Traces Reddit Ads calls with OpenTelemetry.
///
/// `otel_reddit_ads` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Reddit Ads call in
/// [tracedRedditAds]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'reddit-ads-example');

  // Wraps a Reddit Ads API call in a CLIENT span.
  final redditAdsId = await tracedRedditAds<String>(
    operation: 'campaigns.create',
    invoke: () async {
      // Make the Reddit Ads call here, then report what it returned.
      const id = 'reddit_ads_8f3a2c';
      return const RedditAdsCallResult(
          value: id,
          result: RedditAdsResult(
              businessId: 'business_8f3a2c',
              adAccountId: 'adaccount_8f3a2c',
              campaignId: 'campaign_8f3a2c',
              adGroupId: 'adgroup_8f3a2c',
              adId: 'ad_8f3a2c',
              objective: 'BRAND_AWARENESS_AND_REACH',
              bidStrategy: 'BID_STRATEGY_MAX_CPC',
              fundingType: 'BUDGET_AGGREGATE',
              communitiesTargeted: 'r/programming,r/dartlang',
              spendMinor: 1,
              currencyCode: 'usd',
              impressions: 1,
              clicks: 1,
              upvotes: 1,
              comments: 1,
              conversions: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedRedditAds campaigns.create returned $redditAdsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRedditAdsInstrumentationAsync.
  await runWithoutRedditAdsInstrumentationAsync(
    () => tracedRedditAds<String>(
      operation: 'campaigns.create',
      invoke: () async {
        const id = 'reddit_ads_8f3a2c';
        return const RedditAdsCallResult(
            value: id,
            result: RedditAdsResult(
                businessId: 'business_8f3a2c',
                adAccountId: 'adaccount_8f3a2c',
                campaignId: 'campaign_8f3a2c',
                adGroupId: 'adgroup_8f3a2c',
                adId: 'ad_8f3a2c',
                objective: 'BRAND_AWARENESS_AND_REACH',
                bidStrategy: 'BID_STRATEGY_MAX_CPC',
                fundingType: 'BUDGET_AGGREGATE',
                communitiesTargeted: 'r/programming,r/dartlang',
                spendMinor: 1,
                currencyCode: 'usd',
                impressions: 1,
                clicks: 1,
                upvotes: 1,
                comments: 1,
                conversions: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
