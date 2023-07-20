function checkElementPosition(obj,propVal)


    if(size(obj.ElementPosition,1)==1)&&(numel(obj.Element)==1)
        error(message('antenna:antennaerrors:ScalarArray'));
    elseif propVal<size(obj.ElementPosition,1)
        value1=num2str(size(obj.ElementPosition,1));
        value2=num2str(propVal);
        error(message('antenna:antennaerrors:NotEnoughArrayElements',...
        'ElementPosition',value1,value2));
    elseif propVal>size(obj.ElementPosition,1)
        value1=num2str(propVal);
        value2=num2str(size(obj.ElementPosition,1));
        error(message('antenna:antennaerrors:NotEnoughArrayElementPosition',...
        'Element',value1,value2));
    end

end
