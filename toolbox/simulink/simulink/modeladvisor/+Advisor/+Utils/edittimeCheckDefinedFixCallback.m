

function hasFixCallback=edittimeCheckDefinedFixCallback(edittimeClassName,checkID)
    hasFixCallback=false;
    classInstance=eval([edittimeClassName,'(''',checkID,''')']);
    mcInfo=metaclass(classInstance);
    for i=1:length(mcInfo.MethodList)
        if strcmpi(mcInfo.MethodList(i).Name,'fix')&&strcmpi(mcInfo.MethodList(i).DefiningClass.Name,edittimeClassName)

            hasFixCallback=true;
            break;
        end
    end
end
