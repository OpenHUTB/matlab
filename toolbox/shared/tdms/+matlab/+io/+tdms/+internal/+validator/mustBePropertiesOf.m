function mustBePropertiesOf(propertiesA,propertiesB)



    try
        mustBeMember(propertiesA,propertiesB);
    catch ME
        eid="tdms:TDMS:InvalidPropertyName";
        PropEx=MException(eid,message(eid,strjoin(propertiesB,newline)));
        throwAsCaller(PropEx);
    end

end