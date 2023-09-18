// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal;

    constructor(string memory name_, string memory symbol_, uint8 decimal_) {
        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {
    // Declaring an event
    event Test_Event(uint256 a);

    function burn(uint256 amount) public virtual {
        emit Test_Event(balanceOf(_msgSender()));
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MaaLaxmiToken is ERC20, Ownable {
    string private TokenName = "LAXMI-M Coin";
    string private TokenSymbol = "LAXMI-M";
    uint8 private Decimal = 18;
    uint256 private TOTALSUPPLY = 11_000_000_000;

    uint256 public CreationsTime;
    uint256 private Unlocked;

    uint256 public FIRST_PRESALE = 1_000_000_000; // 1 Billion LAXMI tokens
    uint256 public SECOND_PRESALE = 750_000_000; // 750 Million Laxmi token
    uint256 public ICOSALE = 750_000_000; // 750 Million Laxmi token
    uint256 public REWARD_COMMUNITY = 500_000_000; // 500 Million Laxmi token
    uint256 public DONATION = 500_000_000; // 500 Million Laxmi token
    uint256 public INSIDER_ALLOCATION = 1_000_000_000; // 1 Billion LAXMI tokens

    uint256 public LOCKUP_25PER = (TOTALSUPPLY * 25) / 100; // 25% token will be locked for 1 year
    uint256 public LOCKUP_1B_4M = 1_000_000_000; // 1 Billion token will be locked for 4 month
    uint256 public LOCKUP_1B_6M = 1_000_000_000; // 1 Billion token will be locked for 6 month

    constructor() ERC20(TokenName, TokenSymbol, Decimal) {
        uint256 lockedToken = LOCKUP_25PER + LOCKUP_1B_4M + LOCKUP_1B_6M;
        _mint(address(this), lockedToken * 10 ** decimals()); // locked token
        // _mint(0x1f11cb772fDdc636CBc8dc0765Ba84bC1D0D4A50, (TOTALSUPPLY - lockedToken) * 10 ** decimals()); // remaining tokens to deployer
        _mint(msg.sender, (TOTALSUPPLY - lockedToken) * 10 ** decimals()); // remaining tokens to deployer

        CreationsTime = block.timestamp;
    }

    function UnlockToken() public onlyOwner {
        uint256 unlockedAmount;
        if (block.timestamp > CreationsTime + 4 * 30 days) {
            unlockedAmount = LOCKUP_1B_4M * 1 ether;
        }
        if (block.timestamp > CreationsTime + 6 * 30 days) {
            unlockedAmount += LOCKUP_1B_6M * 1 ether;
        }
        if (block.timestamp > CreationsTime + 12 * 30 days) {
            unlockedAmount += LOCKUP_25PER * 1 ether;
        }

        uint256 updatedAmount = unlockedAmount - Unlocked;
        require(updatedAmount != 0, "No tokens for Unlock");

        transfer(msg.sender, updatedAmount);

        Unlocked = unlockedAmount;
    }

    receive() external payable {
        payable(owner()).transfer(msg.value);
    }

    fallback() external payable {}
}
