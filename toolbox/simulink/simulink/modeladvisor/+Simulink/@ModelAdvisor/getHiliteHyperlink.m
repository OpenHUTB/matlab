function hyperlink=getHiliteHyperlink(this,varargin)








    SIDPrefix='SID:';

    if nargin<3
        linkobject=varargin{1};
        objectSID=Simulink.ID.getSID(linkobject);
        if isempty(objectSID)
            hyperlink='';
            return
        end

        objName=encodeStrtoHTMLsymbol(getfullname(linkobject));





        objectSID=[SIDPrefix,objectSID];
        URLstring=['<a href="matlab: modeladvisorprivate hiliteSystem ',objectSID,'">'];

        if~isempty(objName)
            hyperlink=[URLstring,objName{:},'</a>'];
        else
            parentName=get_param(linkobject,'Parent');
            if~isempty(parentName)
                hyperlink=[URLstring,parentName,'/??? </a>'];
            else
                hyperlink=[URLstring,'Name is empty','</a>'];
            end
        end

    else
        index=varargin{1};
        check_index=varargin{2};
        if nargin>3
            checkobj=varargin{3};
        else
            checkobj=this.CheckCellArray{check_index};
        end

        model=getfullname(this.System);
        encodedModelName=modeladvisorprivate('HTMLjsencode',model,'encode');

        FOUND_OBJECTS=checkobj.FoundObjects;
        objName=encodeStrtoHTMLsymbol(FOUND_OBJECTS(index).fullname);
        if isempty(FOUND_OBJECTS(index).SID)
            URLstring=['<a href="matlab: modeladvisorprivate hiliteSystem ',encodedModelName,' ',[num2str(check_index),'_',num2str(index)],'">'];
        else
            URLstring=['<a href="matlab: modeladvisorprivate hiliteSystem ',SIDPrefix,FOUND_OBJECTS(index).SID,'">'];
        end
        if~isempty(objName)
            hyperlink=[URLstring,objName{:},'</a>'];
        else
            parentName=get_param(FOUND_OBJECTS(index).handle,'Parent');
            if~isempty(parentName)
                hyperlink=[URLstring,parentName,'/??? </a>'];
            else
                hyperlink=[URLstring,'Name is empty','</a>'];
            end
        end

    end


    function dstString=encodeStrtoHTMLsymbol(srcString)
        EncodeTable=...
        {'<','&#60;';...
        '>','&#62;';...
        '&','&#38;';...
        '#','&#35;';...
        };

        dstString='';
        for i=1:length(srcString)
            for j=1:length(EncodeTable)
                dstSubString=strrep(srcString(i),EncodeTable(j,1),EncodeTable(j,2));
                if~strcmp(dstSubString,srcString(i))
                    break
                end
            end
            dstString=[dstString,dstSubString];%#ok<AGROW>
        end
