import '../model/category.dart';
import '../assets/icons.dart';
import '../assets/colors.dart';

class CategoryController {
  // List containing all Categories
  static final List<Category> categories = [
    // TODO: Change icons and colors
    const Category(index: 0, name: "None", color: blue, iconData: iconTag),
    const Category(
        index: 1, name: "Food", color: warmGreen, iconData: iconRestaurant),
    const Category(
        index: 2, name: "Clothing", color: orange, iconData: iconShopping),
    const Category(
        index: 3, name: "Transportation", color: indigo, iconData: iconTrain),
    const Category(
        index: 4, name: "Entertainment", color: deepPink, iconData: iconTicket),
    const Category(
        index: 5, name: "Fitness", color: deepPurple, iconData: iconFitness),
    const Category(
        index: 6, name: "Housing", color: deepOrange, iconData: iconHouse),
    const Category(
        index: 7,
        name: "Healthcare",
        color: deepCoolGreen,
        iconData: iconMedical),
    const Category(
        index: 8, name: "Restaurants", color: lightRed, iconData: iconFastFood),
    const Category(
        index: 9, name: "Education", color: teal, iconData: iconSchool),
    const Category(index: 10, name: "Books", color: pink, iconData: iconBooks),
    const Category(index: 11, name: "Pets", color: brown, iconData: iconPets),
    const Category(
        index: 12, name: "Vacations", color: amber, iconData: iconVacation),
    const Category(index: 13, name: "Café", color: cyan, iconData: iconCafe),
    // TODO: Not sure what index
    // TODO: Change icon and color
    const Category(
        index: 14, name: "All", color: blueGrey, iconData: iconCategory),
  ];

  // Returns Category at index i
  static Category getCategory(int i) {
    return categories[i];
  }

  // Returns the full list of Categories
  static List<Category> getCategories() {
    return categories;
  }

  // Returns the nbr of Categories
  static int getCategoryCount() {
    return categories.length;
  }
}
