function[dsout,retIndex]=find(this,varargin)































    narginchk(2,inf);
    [varargin{:}]=convertStringsToChars(varargin{:});



    if(nargin==2&&(ischar(varargin{1})||iscell(varargin{1})))

        [dsout,~,retIndex]=locGet(this,{},varargin{:});
        return;
    end


    [dsout,retIndex]=locFind(this,varargin);

end

function[dsout,retIndex]=locFind(ds,varg)




    dsout=Simulink.SimulationData.Dataset;
    dsout.Name=ds.Name;

    try


        inSt=locParseInput(varg);


        checks=locFindObjects(ds,inSt);

        retIndex=find(checks);
        if~isempty(retIndex)
            dsout.Storage_=...
            dsout.Storage_.addElements(1,ds.Storage_.getElements(retIndex));
        end
    catch e
        throwAsCaller(e);
    end
end


function checks=locFindObjects(ds,inSt)

    nElms=numElements(ds);
    inStLen=length(inSt);


    checks=false(1,nElms);

    for idx=1:nElms
        elm=ds.Storage_.getElements(idx);



        str=repmat(' ',1,inStLen*2);
        for pdx=1:inStLen
            pName=inSt(pdx).ParamName;
            pVal=inSt(pdx).ParamValue;

            locCheck=true;
            try
                objPVal=elm.(pName);
            catch
                locCheck=false;
            end

            if locCheck
                if inSt(pdx).RegExp
                    locCheck=locRegExp(objPVal,pVal);
                else
                    try
                        locCheck=isequal(objPVal,pVal);
                    catch me %#ok<NASGU>
                        locCheck=false;
                    end
                end
            end

            if locCheck
                str(2*pdx-1)='1';
            else
                str(2*pdx-1)='0';
            end

            str(2*pdx)=inSt(pdx).OP;
        end

        val=eval(str(1:(end-1)));
        checks(idx)=val;
    end
end

function match=locRegExp(objPVal,pVal)


    match=false;


    [isOkObjVal,objPVal]=regExpArgOk(objPVal);
    isOkPVal=ischar(pVal);


    if~isOkObjVal||~isOkPVal
        Simulink.SimulationData.utError('InvalidDatasetFindInvalidRegExpPValue');
    end

    pVal={pVal};
    matches=regexp(objPVal,pVal,'once','emptymatch');

    for idx=1:numel(matches)
        if~isempty(matches{idx})
            match=true;
            return;
        end
    end
end

function[isOk,retCell]=regExpArgOk(in)



    isOk=true;
    retCell={};

    if isa(in,'Simulink.SimulationData.BlockPath')
        if numel(in)==1
            retCell=convertToCell(in);
        else


            retCell={};
            for idx=1:numel(in)
                retCell=[retCell,convertToCell(in(idx))];%#ok<AGROW>
            end
        end
    elseif ischar(in)
        retCell={in};
    else
        isOk=false;
    end

end

function ret=locParseInput(input)






    sdef=struct('RegExp',false,'ParamName','','ParamValue',[],'OP','&');
    ret=repmat(sdef,0);


    len=length(input);
    if len<2
        Simulink.SimulationData.utError('InvalidDatasetFindInvalidNumInputs');
    end







    idx=1;
    while(idx<=len)


        [idx,isRegExp]=locProcessRegExp(input,idx);
        sdef.RegExp=isRegExp;


        if idx+1<=len&&isvarname(input{idx})
            sdef.ParamName=input{idx};
            sdef.ParamValue=input{idx+1};
            idx=idx+2;
        else
            Simulink.SimulationData.utError('InvalidDatasetFindInvalidParamValuePair');
        end


        sdef.OP='&';
        if idx<=len
            [idx,op]=locProcessAndOr(input,idx,len);
            sdef.OP=op;
        end


        ret(end+1)=sdef;%#ok
    end

end

function[idx,isRegExp]=locProcessRegExp(input,idx)



    isRegExp=false;

    val=input{idx};
    if~isempty(val)&&ischar(val)
        if isequal(val(1),'-')
            if strcmp(val,'-regexp')
                isRegExp=true;

                idx=idx+1;
            else
                Simulink.SimulationData.utError('InvalidDatasetFindInvalidRegExpOption',val);
            end
        end
    end

end

function[idx,op]=locProcessAndOr(input,idx,len)



    op='&';

    val=input{idx};
    if~isempty(val)&&ischar(val)&&(val(1)=='-')

        if idx<len&&strcmp(val,'-or')
            op='|';
            idx=idx+1;
        elseif idx<len&&strcmp(val,'-and')
            idx=idx+1;
        elseif strcmp(val,'-regexp')

        else
            Simulink.SimulationData.utError('InvalidDatasetFindInvalidOptions',val);
        end
    end

end



