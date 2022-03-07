const simplifyAddress = (address: string | null): string => {

    if (!address) return '';

    // pick out the first 4 and last 4 of the address
    return address.substring(0, 8) + '...' + address.substring(address.length - 8);

}

export { simplifyAddress };