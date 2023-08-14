function CInfo=getBlockInfo(this,hC)%#ok




    [props,values]=getPVPairs(hC);
    CInfo.Countertype=getvalue(hC,'Counttype',props,values);
    CInfo.InitValues=getvalue(hC,'CountInit',props,values);
    CInfo.StepValue=getvalue(hC,'CountStep',props,values);
    CInfo.FromType=getvalue(hC,'CountFromType',props,values);

    if strcmpi(CInfo.Countertype,'Count Limited')||...
        strcmpi(CInfo.Countertype,'Modulo')
        CInfo.CountToValue=getvalue(hC,'CountMax',props,values);
    else
        CInfo.CountToValue=[];
    end

    if strcmpi(CInfo.FromType,'Specify')
        CInfo.CountFromValue=getvalue(hC,'CountFrom',props,values);
    else
        CInfo.CountFromValue=CInfo.InitValues;
    end


    CInfo.Localresetport=getvalue(hC,'CountResetPort',props,values);
    CInfo.Loadport=getvalue(hC,'CountLoadPort',props,values);
    CInfo.Countenableport=getvalue(hC,'CountEnbPort',props,values);
    CInfo.CountdirectionPort=getvalue(hC,'CountDirPort',props,values);
    CInfo.CounthitPort=getvalue(hC,'CountHitOutputPort',props,values);
end


function value=getvalue(hC,property,props,values)
    bfp=hC.SimulinkHandle;
    if bfp>0
        for ii=1:length(props)
            if strcmpi(props{ii},property)
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
end


function[props,values]=getPVPairs(hC)
    bfp=hC.SimulinkHandle;
    if bfp>0

        pat={'\s+',':'};
        numeric_props=['CountInit','CountStep','CountMax','CountFrom','CountWordLen','CountFracLen','CountSamptime'];
        props=regexprep(get_param(bfp,'MaskNames'),pat,'');
        values=get_param(bfp,'MaskValues');
        for i=1:length(props)
            if strfind(numeric_props,props{i})
                values{i}=hdlslResolve(props{i},bfp);
            end
        end
    else
        props='';
        values=[];
    end
end


