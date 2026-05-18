// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_reddit_ads/otel_reddit_ads.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_reddit_ads-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('report.run records subreddit targeting + upvotes', () async {
    await tracedRedditAds<String>(
      operation: 'report.run',
      invoke: () async => const RedditAdsCallResult(
        value: 'ok',
        result: RedditAdsResult(
          businessId: 'b_1',
          adAccountId: 'aa_1',
          campaignId: 'cam_1',
          objective: 'TRAFFIC',
          bidStrategy: 'BID_STRATEGY_MAX_CPC',
          fundingType: 'BUDGET_AGGREGATE',
          communitiesTargeted: 'r/programming,r/dartlang,r/flutterdev',
          spendMinor: 75000,
          currencyCode: 'USD',
          impressions: 25000,
          clicks: 380,
          upvotes: 240,
          comments: 18,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('reddit_ads report.run')!);
    expect(a['reddit_ads.objective'], 'TRAFFIC');
    expect(a['reddit_ads.communities.targeted'],
        'r/programming,r/dartlang,r/flutterdev');
    expect(a['reddit_ads.spend.minor'], 75000);
    expect(a['reddit_ads.upvotes'], 240);
    expect(a['reddit_ads.comments'], 18);
  });

  test('HTTP 422 sets span error', () async {
    await tracedRedditAds<String>(
      operation: 'ads.create',
      invoke: () async => const RedditAdsCallResult(
        value: 'ok',
        result: RedditAdsResult(statusCode: 422),
      ),
    );
    expect(
      spans.findSpanByName('reddit_ads ads.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutRedditAdsInstrumentationAsync(() async {
      await tracedRedditAds<String>(
        operation: 'funding.list',
        invoke: () async => const RedditAdsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('reddit_ads '), isEmpty);
  });
}
