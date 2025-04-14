// controllers/itemController.js
const itemService = require("../services/itemService");
const { successResponse, errorResponse } = require("../utils/responseHandler");

class ItemController {
  // Retrieve all items
  async getItems(req, res) {
    try {
      const items = await itemService.getAllItems();
      return successResponse(res, 200, "Items retrieved successfully", items);
    } catch (error) {
      return errorResponse(res, 500, "Error retrieving items", error);
    }
  }

  // Create a new item
  async createItem(req, res) {
    try {
      const { name, description, price, category } = req.body;

      // Validate required fields
      if (!name || !price) {
        return errorResponse(res, 400, "⚠️ Name and Price are required!");
      }

      // Create the new item
      const newItem = await itemService.createItem({
        name,
        description: description || "",
        price: parseInt(price),
        category: category || "Uncategorized",
      });

      return successResponse(res, 201, "✅ Item added successfully!", newItem);
    } catch (error) {
      return errorResponse(res, 500, "Error adding item", error);
    }
  }
}

module.exports = new ItemController();
