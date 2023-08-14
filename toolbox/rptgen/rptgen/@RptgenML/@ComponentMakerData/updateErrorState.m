function updateErrorState(this,varargin)





    errMsg='';

    propName='PropertyName';

    nameVal=getVal(this,propName,varargin);

    if isempty(nameVal)
        p=findprop(this,propName);
        errMsg=getString(message('rptgen:RptgenML_ComponentMakerData:mustNotBeEmptyMsg',errMsg,p.Description));
    else
        lSib=left(this);
        nameFound=false;
        while~isempty(lSib)&&~nameFound
            nameFound=isa(lSib,'RptgenML.ComponentMakerData')&&strcmpi(lSib.(propName),nameVal);
            lSib=left(lSib);
        end
        rSib=right(this);
        while~isempty(rSib)&&~nameFound
            nameFound=isa(rSib,'RptgenML.ComponentMakerData')&&strcmpi(rSib.(propName),nameVal);
            rSib=right(rSib);
        end

        if nameFound
            p=findprop(this,propName);
            errMsg=getString(message('rptgen:RptgenML_ComponentMakerData:nonUniqueMsg',errMsg,p.Description,nameVal));
        end
    end

    dtVal=getVal(this,'DataTypeString',varargin);

    if isempty(dtVal)
        p=findprop(this,'DataTypeString');
        errMsg=getString(message('rptgen:RptgenML_ComponentMakerData:cannotBeEmptyMsg',errMsg,p.Description));
    elseif strcmpi(dtVal,'!enumeration')

        eVals=getVal(this,'EnumValues',varargin);
        if isempty(eVals)
            errMsg=getString(message('rptgen:RptgenML_ComponentMakerData:mustHaveEnumMsg',errMsg));
        else
            fVal=getVal(this,'FactoryValueString',varargin);
            if length(fVal)<3||~any(strcmp(eVals,fVal(2:end-1)))
                p=findprop(this,'FactoryValueString');
                errMsg=getString(message('rptgen:RptgenML_ComponentMakerData:invalidEnumMsg',...
                errMsg,p.Description,fVal));
            end
        end
    end

    if~isempty(errMsg)
        errMsg=errMsg(1:end-1);
    end

    this.ErrorMessage=errMsg;


    function val=getVal(this,propName,args)

        propIdx=find(strcmpi(args,propName));
        if isempty(propIdx)
            val=get(this,propName);
        else
            val=args{propIdx(1)+1};
        end



