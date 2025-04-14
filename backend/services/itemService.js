// services/itemService.js
const Item = require("../model/Item");

class ItemService {
  async getAllItems(query = {}) {
    try {
      const items = await Item.find(query);
      return items;
    } catch (error) {
      throw error;
    }
  }
  async createItem(data) {
    try {
      const newItem = new Item(data);
      return await newItem.save();
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ItemService();
