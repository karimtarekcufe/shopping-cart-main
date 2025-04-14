// utils/responseHandler.js
exports.successResponse = (res, statusCode, message, data) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

exports.errorResponse = (res, statusCode, message, error) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error: error.message,
  });
};
