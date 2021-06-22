// SPDX-License-Identifier: Bityield
pragma solidity 0.6.10;

/**
* @title Uint256ArrayUtils
* @author Bityield
*
* Utility functions to handle Uint256 Arrays
*/
library Uint256ArrayUtils {
	/**
	 * Returns the combination of the two arrays
	 * @param a The first array
	 * @param b The second array
	 * @return Returns a extended by b
	 */
	function extend(uint256[] memory a, uint256[] memory b) internal pure returns (uint256[] memory) {
		uint256 aLength = a.length;
		uint256 bLength = b.length;
		uint256[] memory newUints = new uint256[](aLength + bLength);
		
		for (uint256 i = 0; i < aLength; i++) {
			newUints[i] = a[i];
		}

		for (uint256 j = 0; j < bLength; j++) {
			newUints[aLength + j] = b[j];
		}

		return newUints;
	}
}