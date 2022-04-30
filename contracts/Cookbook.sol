// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CookbookBase {
    event IngredientCreated(uint256 ingredientId, bytes32 name, uint256 gene);
    event RecipeCreated(address owner, uint256 recipeId, bytes32 name, uint256 gene);
    event Transfer(address from, address to, uint256 tokenId);

    struct Ingredient{
        uint256 gene;
        bytes32 name;
    }

    struct Recipe{
        uint256 gene;
        bytes32 name;
        Ingredient[] ingredients;
        uint16[] ingredientsQuantity;
    }

    Ingredient[] ingredientPool;
    Recipe[] recipes;

    mapping(uint256 => address) recipeIndexToOwner;
    mapping(address => uint256) ownershipRecipeCount;

    function _assignOwnership(address _from, address _to, uint256 _tokenId) internal {
        ownershipRecipeCount[_to]++;
        recipeIndexToOwner[_tokenId] = _to;
        if(_from != address(0)){
            ownershipRecipeCount[_from]--;
        }
        emit Transfer(_from, _to, _tokenId);
    }

    function createIngredient(uint256 _gene, bytes32 _name) external returns(uint) {
        Ingredient memory _ingredient = Ingredient({
            gene: _gene,
            name: _name
        });

        ingredientPool.push(_ingredient);

        uint256 newIngredientId = ingredientPool.length - 1;

        emit IngredientCreated(newIngredientId, _name, _gene);

        return newIngredientId;
    }

    function createRecipe(uint256 _gene, bytes32 _name, Ingredient[] memory _ingredient, uint16[] memory _ingredientQuantity, address _owner) external returns(uint) {
        Recipe memory _recipe = Recipe({
            gene: _gene,
            name: _name,
            ingredients: _ingredient,
            ingredientsQuantity: _ingredientQuantity
        });

        recipes.push(_recipe);

        uint256 newRecipeId = recipes.length - 1;

        emit RecipeCreated(_owner, _gene, _name, newRecipeId);

        _assignOwnership(address(0), _owner, newRecipeId);

        return newRecipeId;
    }

    function getRecipe(uint256 _id) external view returns(bytes32 name, Ingredient[] memory ingredient, uint16[] memory ingredientQuantity, uint256 gene){
        Recipe storage recipe = recipes[_id];
        name = bytes32(recipe.name);
        ingredient = recipe.ingredients;
        ingredientQuantity = recipe.ingredientsQuantity;
        gene = uint256(recipe.gene);
    }

    function balanceOf(address _owner) public view returns(uint256 count){
        return ownershipRecipeCount[_owner];
    }

    function totalSupply() public view returns(uint){
        return recipes.length - 1;
    }

    function recipesOfOwner(address _owner) external view returns(uint256[] memory ownerRecipes){
        uint256 recipeCount = balanceOf(_owner);

        if(recipeCount == 0){
            return new uint256[](0);
        }
        else{
            uint256[] memory result = new uint256[](recipeCount);
            uint256 totalRecipes = totalSupply();
            uint256 resultIndex = 0;

            uint256 recipeId;
            for(recipeId = 0; recipeId <= totalRecipes; recipeId ++){
                if(recipeIndexToOwner[recipeId] == _owner){
                    result[resultIndex] = recipeId;
                    resultIndex ++;
                }
            }
            return result;
        }

    }
}
