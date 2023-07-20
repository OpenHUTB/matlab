function checksum=computeModelTopologyChecksum(this,input)






    hashFn=pmsl_private('pmsl_modeltopologychecksum');
    checksum=hashFn(input);





