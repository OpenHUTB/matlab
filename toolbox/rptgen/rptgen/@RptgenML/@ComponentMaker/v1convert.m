function v1convert(h,v1component)






    if isa(v1component,'rptcp')
        v1component=unpoint(v1component);
    elseif isa(v1component,'rptcomponent')

    elseif ischar(v1component)
        try
            v1component=unpoint(feval(v1component));
        catch ME
            warning('RPTGEN:CanNotConvertV1','%s',ME.message);
            return;
        end
    else
        warning(message('rptgen:RptgenML_ComponentMaker:v1ConvertError'));
        return;
    end

    v1ClassName=class(v1component);
    h.ClassName=v1ClassName;
    h.v1ClassName=v1ClassName;

    g=getinfo(v1component);

    h.DisplayName=g.Name;
    h.Description=g.Desc;

    act=allcomptypes();
    actIndex=find(strcmp({act.Type},g.Type));
    if~isempty(actIndex)
        typeStr=act(actIndex(1)).Fullname;
    else
        typeStr='Custom';
    end

    h.Type=typeStr;

    h.Parentable=(~isempty(g.ValidChildren)&&g.ValidChildren{1});

    h.v1ExecuteFile=which([v1ClassName,'/execute']);
    h.v1OutlinestringFile=which([v1ClassName,'/outlinestring']);

    if~isempty(v1component.att)
        f=fieldnames(v1component.att);

        for i=1:length(f)
            atx=getattx(v1component,f{i});
            h.addProperty(atx);
        end
    end

    function list=allcomptypes()


        regfiles=which('rptcomps.xml','-all');
        idList={};
        nameList={};
        for i=1:length(regfiles)
            [tempID,tempName]=LocParseRegistry(regfiles{i});
            idList=[idList,tempID];%#ok
            nameList=[nameList,tempName];%#ok
        end

        list=struct('Type',idList,'Fullname',nameList,'Expand',true);

        [~,sortedIndex]=sort(nameList);
        list=list(sortedIndex);

        i=1;
        while i<length(list)
            if strcmp(list(i).Type,list(i+1).Type)
                list=[list(1:i),list(i+2:end)];
            else
                i=i+1;
            end
        end



        function[idText,nameText]=LocParseRegistry(filename)


            fid=fopen(filename,'r');
            if fid>0
                regText=fread(fid,'*char')';
                fclose(fid);
            else
                regText='';
            end


            regText=LocBetweenTag(regText,'registry');


            typeText=LocBetweenTag([regText{:},' '],'typelist');
            idText=strrep(LocBetweenTag([typeText{:},' '],'id'),...
            '&amp;','&');
            nameText=strrep(LocBetweenTag([typeText{:},' '],'name'),...
            '&amp;','&');


            function between=LocBetweenTag(all,tagname)

                between={};
                openTag=['<',tagname,'>'];
                closeTag=['</',tagname,'>'];

                openLoc=strfind(all,openTag)+length(openTag);
                closeLoc=strfind(all,closeTag)-1;

                for i=length(openLoc):-1:1
                    between{i}=all(openLoc(i):closeLoc(i));
                end

