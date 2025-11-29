import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  // Initialize Razorpay
  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  // Open Razorpay checkout
  void openCheckout({
    required double amount,
    required String planName,
    required String userEmail,
    required String userPhone,
    required String userName,
    String? orderId,
  }) {
    try {
      var options = {
        'key':'rzp_test_RSdtuJrYr1Hq8D', // Replace with your actual Razorpay key
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'Navyug Digital',
        'description': 'Registration for $planName',
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'image':'https://navyugdigital.in/public/uploads/favicon/favicon-1756643749.jpg'
        'external': {
          'wallets': ['paytm']
        },
      };

      if (orderId != null) {
        options['order_id'] = orderId;
      }

      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      if (onPaymentError != null) {
        // Create a custom error response since we can't create PaymentFailureResponse directly
        _handlePaymentError(PaymentFailureResponse(
          0, // code
          'Failed to open payment gateway: $e', // message
          null, // error
        ));
      }
    }
  }

  // Dispose Razorpay
  void dispose() {
    _razorpay.clear();
  }
}

// Payment callback functions
typedef PaymentSuccessCallback = void Function(PaymentSuccessResponse response);
typedef PaymentErrorCallback = void Function(PaymentFailureResponse response);
typedef ExternalWalletCallback = void Function(ExternalWalletResponse response);
