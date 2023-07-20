classdef ExcelMappingInfo<slreq.import.ui.MappingInfo




    properties
        columnIndex;
        columnOptions;
        rawColumns;
        userColumns;

    end

    methods
        function this=ExcelMappingInfo(columnIndex,columnOptions,rawColumns,userColumns)
            this@slreq.import.ui.MappingInfo();

            this.columnIndex=columnIndex;
            this.columnOptions=columnOptions;
            this.rawColumns=rawColumns;
            this.userColumns=userColumns;

        end

        function out=doit(this)
            out=[];

            this.initMapping();



            this.options.description='NOT-FOR-EXPORT';


            stringType=slreq.datamodel.AttributeTypeEnum.String;





            idColumn=find(this.columnOptions==slreq.import.propNameMap('customId'));
            if~isempty(idColumn)
                this.mapToBuiltIn(this.rawColumns{idColumn},stringType,'customId',stringType);
            end

            summaryColumn=find(this.columnOptions==slreq.import.propNameMap('summary'));
            if~isempty(summaryColumn)
                this.mapToBuiltIn(this.rawColumns{summaryColumn},stringType,'summary',stringType);
            end

            descriptionColumn=find(this.columnOptions==slreq.import.propNameMap('description'));

            for ii=1:length(descriptionColumn)
                this.mapToBuiltIn(this.rawColumns{descriptionColumn(ii)},stringType,'description',stringType);
            end

            rationaleColumn=find(this.columnOptions==slreq.import.propNameMap('rationale'));
            if~isempty(rationaleColumn)
                this.mapToBuiltIn(this.rawColumns{rationaleColumn},'String','rationale',stringType);
            end

            keywordsColumn=find(this.columnOptions==slreq.import.propNameMap('keywords'));
            if~isempty(keywordsColumn)
                this.mapToBuiltIn(this.rawColumns{keywordsColumn},'String','keywords',stringType);
            end

            attributeColumn=find(this.columnOptions==slreq.import.propNameMap('ATTR'));
            for idx=1:length(attributeColumn)
                origIdx=attributeColumn(idx);
                this.mapToCustomAttribute(this.rawColumns{origIdx},stringType,this.userColumns{origIdx},stringType,false);
            end










        end

    end
end

