// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyMarketPlace {

    event List(address indexed owner, Product product);
    event Sale(address indexed buyer, Product product);
    event Withdraw(address indexed owner, uint256 amount);

    struct Product {
        string name;
        string description;
        uint256 price;
        address owner;
    }

    Product[] public products;
    mapping(address => uint256) public wallet;

    function listItem(string memory _name, string memory _desc, uint256 _price) external {
        Product memory product = Product({
            name: _name,
            description: _desc,
            price: _price,
            owner: msg.sender
        });
        products.push(product);
        emit List(msg.sender, product);
    }

    function saleItem(uint256 _index) external payable {
        require(_index < products.length, "Product does not exist");
        Product memory product = products[_index];
        require(msg.value == product.price, "Incorrect value sent");
        require(product.owner != msg.sender, "Buyer cannot be the seller");

        wallet[product.owner] += msg.value;
        products[_index].owner = msg.sender;

        emit Sale(msg.sender, product);
    }

    function withdraw(uint256 _amount) external {
        require(wallet[msg.sender] >= _amount, "Insufficient funds");
        wallet[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function listAllItems() external view returns (Product[] memory) {
        return products;
    }
}
