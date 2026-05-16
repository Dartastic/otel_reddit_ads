// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_reddit_ads_suppression.dart';

const _tracerName = 'dartastic_otel_libs_reddit_ads';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class RedditAdsResult {
  const RedditAdsResult({
    this.businessId,
    this.adAccountId,
    this.campaignId,
    this.adGroupId,
    this.adId,
    this.objective,
    this.bidStrategy,
    this.fundingType,
    this.communitiesTargeted,
    this.spendMinor,
    this.currencyCode,
    this.impressions,
    this.clicks,
    this.upvotes,
    this.comments,
    this.conversions,
    this.statusCode,
  });

  final String? businessId;
  final String? adAccountId;
  final String? campaignId;
  final String? adGroupId;
  final String? adId;

  /// `BRAND_AWARENESS_AND_REACH` / `TRAFFIC` / `CONVERSIONS` /
  /// `APP_INSTALLS` / `VIDEO_VIEWS` / `CATALOG_SALES` / `ENGAGEMENT`.
  final String? objective;

  /// `BID_STRATEGY_MAX_CPC` / `BID_STRATEGY_MAX_CPM` /
  /// `BID_STRATEGY_AUTOBID`.
  final String? bidStrategy;

  /// `BUDGET_AGGREGATE` / `PER_AD_GROUP` — how budget is shared.
  final String? fundingType;

  /// Comma-separated subreddit names targeted (e.g.,
  /// `r/programming,r/dartlang`).
  final String? communitiesTargeted;

  /// Spend in minor units.
  final int? spendMinor;

  final String? currencyCode;
  final int? impressions;
  final int? clicks;

  /// Reddit-specific engagement: upvotes on the promoted post.
  final int? upvotes;

  final int? comments;
  final int? conversions;
  final int? statusCode;
}

class RedditAdsCallResult<T> {
  const RedditAdsCallResult({required this.value, this.result});
  final T value;
  final RedditAdsResult? result;
}

/// Wraps a Reddit Ads API call in a CLIENT span. [operation] is one
/// of `report.run`, `campaigns.create`, `ad_groups.create`,
/// `ads.create`, `audiences.create`, `events.send`, `funding.list`.
Future<T> tracedRedditAds<T>({
  required String operation,
  required Future<RedditAdsCallResult<T>> Function() invoke,
}) async {
  if (redditAdsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'reddit_ads',
    'rpc.method': operation,
    'reddit_ads.operation': operation,
  };

  final span = _tracer().startSpan(
    'reddit_ads $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.businessId != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.business.id',
          r.result!.businessId!,
        ));
      }
      if (r.result!.adAccountId != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.ad_account.id',
          r.result!.adAccountId!,
        ));
      }
      if (r.result!.campaignId != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.campaign.id',
          r.result!.campaignId!,
        ));
      }
      if (r.result!.adGroupId != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.ad_group.id',
          r.result!.adGroupId!,
        ));
      }
      if (r.result!.adId != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.ad.id',
          r.result!.adId!,
        ));
      }
      if (r.result!.objective != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.objective',
          r.result!.objective!,
        ));
      }
      if (r.result!.bidStrategy != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.bid.strategy',
          r.result!.bidStrategy!,
        ));
      }
      if (r.result!.fundingType != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.funding.type',
          r.result!.fundingType!,
        ));
      }
      if (r.result!.communitiesTargeted != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.communities.targeted',
          r.result!.communitiesTargeted!,
        ));
      }
      if (r.result!.spendMinor != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.spend.minor',
          r.result!.spendMinor!,
        ));
      }
      if (r.result!.currencyCode != null) {
        extras.add(OTel.attributeString(
          'reddit_ads.currency.code',
          r.result!.currencyCode!,
        ));
      }
      if (r.result!.impressions != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.impressions',
          r.result!.impressions!,
        ));
      }
      if (r.result!.clicks != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.clicks',
          r.result!.clicks!,
        ));
      }
      if (r.result!.upvotes != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.upvotes',
          r.result!.upvotes!,
        ));
      }
      if (r.result!.comments != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.comments',
          r.result!.comments!,
        ));
      }
      if (r.result!.conversions != null) {
        extras.add(OTel.attributeInt(
          'reddit_ads.conversions',
          r.result!.conversions!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Reddit Ads HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
