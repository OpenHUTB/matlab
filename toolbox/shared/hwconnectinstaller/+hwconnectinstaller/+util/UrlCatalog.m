classdef UrlCatalog<handle















    properties(Access=private)
Map
    end

    methods(Access=public)
        function obj=UrlCatalog(xmlFileName)
            validateattributes(xmlFileName,{'char'},{'nonempty'},'UrlCatalog');

            obj.Map=containers.Map('KeyType','char','ValueType','char');

            try

                domNode=parseFile(matlab.io.xml.dom.Parser,xmlFileName);
            catch ME
                error(message('hwconnectinstaller:urlcatalog:UnableToReadXmlFile',xmlFileName,ME.getReport()));
            end

            entryNodes=domNode.getElementsByTagName('entry');

            for i=1:entryNodes.getLength
                node=entryNodes.item(i-1);
                key=char(node.getAttribute('name'));
                value=char(node.getTextContent());

                if isempty(key)
                    warning(message('hwconnectinstaller:urlcatalog:EmptyKey',xmlFileName));
                end

                keyCheck=regexp(key,'[:\w]*','match');
                if numel(keyCheck)==0||(numel(keyCheck{1})~=numel(key))
                    warning(message('hwconnectinstaller:urlcatalog:InvalidKey',key,xmlFileName));
                end

                obj.Map(key)=value;
            end

        end


        function modifiedStr=replaceTokens(obj,originalStr)







            tokens=regexp(originalStr,'\$\[([:\w]+)\]','tokens');
            modifiedStr=originalStr;
            for i=1:numel(tokens)
                token=tokens{i}{1};
                searchExpr=regexptranslate('escape',['$[',token,']']);
                if obj.Map.isKey(token)
                    replaceStr=obj.Map(token);
                    modifiedStr=regexprep(modifiedStr,searchExpr,replaceStr);
                else




                end
            end
        end

        function tokens=getAllTokens(obj)
            tokens=keys(obj.Map);
        end

        function value=lookupToken(obj,token)
            validateattributes(token,{'char'},{'nonempty'},'lookupToken');
            value=obj.Map(token);
        end


        function groupList=getTokenGroups(obj)
            allKeys=keys(obj.Map);
            groupList=cell(1,numel(allKeys));
            for i=1:numel(allKeys)
                splits=strsplit(allKeys{i},':');
                groupList{i}=splits{1};
            end
            groupList=unique(groupList);
        end

    end

    methods(Static,Hidden,Access=public)

        function createEmptyUrlCatalogFile(xmlFileName)
            fid=fopen(xmlFileName,'wt','native','UTF-8');
            assert(fid>=0,sprintf('Unable to open %s for writing',xmlFileName));
            cleanup=onCleanup(@()fclose(fid));
            fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
            fprintf(fid,'<lookupTable>\n');
            fprintf(fid,'</lookupTable>\n');
        end
    end
end
