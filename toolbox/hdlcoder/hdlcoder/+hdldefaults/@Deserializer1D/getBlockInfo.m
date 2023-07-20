function CInfo=getBlockInfo(this,hC)%#ok




    [properties,values]=getPVPairs(hC);


    CInfo.Ratio=getvalue(hC,'Ratio',properties,values);
    CInfo.IdleCycles=getvalue(hC,'IdleCycles',properties,values);
    CInfo.InitialCondition=getvalue(hC,'InitialCondition',properties,values);
    CInfo.startInPort=getvalue(hC,'startIn',properties,values);
    CInfo.validInPort=getvalue(hC,'validIn',properties,values);
    CInfo.validOutPort=getvalue(hC,'validOut',properties,values);



    function value=getvalue(hC,property,properties,values)
        bfp=hC.SimulinkHandle;
        if bfp>0
            for ii=1:length(properties)
                if strcmpi(properties{ii},property)
                    value=values{ii};
                    if strcmpi(value,'off')
                        value=false;
                    elseif strcmpi(value,'on')
                        value=true;
                    end
                    break;
                end
            end
        else
            value=hC.HDLUserData;
        end


        function[properties,values]=getPVPairs(hC)
            bfp=hC.SimulinkHandle;
            if bfp>0
                pat={'\s+',':'};
                numeric_properties=['Ratio','IdleCycles','InitialCondition'];
                properties=regexprep(get_param(bfp,'MaskNames'),pat,'');
                values=get_param(bfp,'MaskValues');
                for i=1:length(properties)
                    if findstr(numeric_properties,properties{i})%#ok<FSTR>
                        values{i}=hdlslResolve(properties{i},bfp);
                    end
                end
            else
                properties='';
                values=[];
            end
