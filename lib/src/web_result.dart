import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hesabe/hesabe.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebScreenResult extends StatefulWidget {
  final String paymentURL;
  final String? responseUrl;
  final String? failureUrl;

  WebScreenResult({
    required this.paymentURL,
    this.responseUrl,
    this.failureUrl,
  });

  @override
  _WebScreenResultState createState() => _WebScreenResultState();
}

class _WebScreenResultState extends State<WebScreenResult> {
  bool flag = false;
  late final InAppWebViewController _controller;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(Hesabe.EVENT_PAYMENT_CANCELLED_BY_USER);
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.paymentURL)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useOnDownloadStart: true,

                  ),
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  if (!flag) {
                    _controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.paymentURL)));
                  }
                },
                onLoadStart: (controller, url) {
                  log('onLoadStart $url');
                },
                onLoadStop: (controller, url) async {
                  /* Check if URL contains the value given at 'responseUrl' field */
                  if (widget.responseUrl != null && url.toString().contains(widget.responseUrl!)) {
                    if (mounted) {
                      setState(() {
                        flag = true;
                      });
                    }
                    /* If yes, parse the result */
                    await parseResult(url.toString());
                  } else if (widget.failureUrl != null && url.toString().contains(widget.failureUrl!)) {
                    if (mounted) {
                      setState(() {
                        flag = true;
                      });
                    }
                    await parseResult(url.toString());
                  }
                },
                onProgressChanged: (controller, progress) {
                  // Handle progress changes if needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> parseResult(String url) async {
    final parse = Uri.parse(url);
    final data = parse.queryParameters['data'];
    Navigator.of(context).pop(data);
  }
}
