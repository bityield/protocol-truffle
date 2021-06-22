// SPDX-License-Identifier: Bityield
pragma solidity 0.6.10;

/**
* @title AddressArrayUtils
* @author Bityield
*
* Utility functions to handle Address Arrays
*/
library AddressArrayUtils {
	
	/**
	 * Finds the index of the first occurrence of the given element.
	 * @param a The input array to search
	 * @param aA The value to find
	 * @return Returns (index and isIn) for the first occurrence starting from index 0
	 */
	function indexOf(address[] memory a, address aA) internal pure returns (uint256, bool) {
		uint256 length = a.length;

		for (uint256 i = 0; i < length; i++) {
			if (a[i] == aA) {
				return (i, true);
			}
		}

		return (uint256(-1), false);
	}
	
	/**
	* Returns true if the value is present in the list. Uses indexOf internally.
	* @param a The input array to search
	* @param aA The value to find
	* @return Returns isIn for the first occurrence starting from index 0
	*/
	function contains(address[] memory a, address aA) internal pure returns (bool) {
		(, bool isIn) = indexOf(a, aA);
		return isIn;
	}
	
	/**
	* Returns true if there are 2 elements that are the same in an array
	* @param a The input array to search
	* @return Returns boolean for the first occurrence of a duplicate
	*/
	function hasDuplicate(address[] memory a) internal pure returns(bool) {
		require(a.length > 0, "a is empty");
	
		for (uint256 i = 0; i < a.length - 1; i++) {
			address current = a[i];
			for (uint256 j = i + 1; j < a.length; j++) {
				if (current == a[j]) {
					return true;
				}
			}
		}

		return false;
	}
	
	/**
	 * @param a The input array to search
	 * @param aA The address to remove     
	 * @return Returns the array with the object removed.
	 */
	function remove(address[] memory a, address aA)
		internal
		pure
		returns (address[] memory)
	{
		(uint256 index, bool isIn) = indexOf(a, aA);
		if (!isIn) {
			revert("Address not in array.");
		} else {
			(address[] memory res,) = pop(a, index);
			return res;
		}
	}
	
	/**
	* Removes specified index from array
	* @param a The input array to search
	* @param index The index to remove
	* @return Returns the new array and the removed entry
	*/
	function pop(address[] memory a, uint256 index)
		internal
		pure
		returns (address[] memory, address)
	{
		uint256 length = a.length;
		require(index < a.length, "Index must be < a length");
		address[] memory newAddresses = new address[](length - 1);
		for (uint256 i = 0; i < index; i++) {
			newAddresses[i] = a[i];
		}
		for (uint256 j = index + 1; j < length; j++) {
			newAddresses[j - 1] = a[j];
		}
		return (newAddresses, a[index]);
	}
	
	/**
	 * Returns the combination of the two arrays
	 * @param a The first array
	 * @param b The second array
	 * @return Returns A extended by B
	 */
	function extend(address[] memory a, address[] memory b) internal pure returns (address[] memory) {
		uint256 aLength = a.length;
		uint256 bLength = b.length;
		address[] memory newAddresses = new address[](aLength + bLength);

		for (uint256 i = 0; i < aLength; i++) {
			newAddresses[i] = a[i];
		}

		for (uint256 j = 0; j < bLength; j++) {
			newAddresses[aLength + j] = b[j];
		}

		return newAddresses;
	}
}