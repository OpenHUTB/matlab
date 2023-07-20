

classdef OSLCQueryBuilderDlg<handle



    properties

        caller;
        srcDoc;


        serverLoginInfo;
        queryString;
        queryParts;
        filterParts;
        partIsTypeDependent;
        typeIsSelected;
        typeFilterIdx;
        showRawQuery;

        userSubjects={'CreatedBy','ModifiedBy'};
        dateSubjects={'CreatedOn','ModifiedOn'};
        dateObject;

        types;
        attributeNames;
        attributeValues;
        selectedTypeIdx;
        selectedType;
        reqIf;


        newParamWanted;
        builtinParams;
        selectedParamIdx;
        selectedPredicateIdx;
        selectedValueIdx;
        textInputValue;
        usedParamNames;
        availableParamNames;
        availablePredicates;
        availableValues;
        isEnumeratedValue;
        isDate;
    end


    properties(Constant)
    end

    methods
        function this=OSLCQueryBuilderDlg()
            this.caller=[];
            this.queryString='';
            this.queryParts={};
            this.filterParts={};
            this.partIsTypeDependent=false(0);
            this.typeIsSelected=false;
            this.typeFilterIdx=0;
            this.showRawQuery=false;
            this.types={};
            this.attributeNames={};
            this.attributeValues={};
            this.selectedTypeIdx=0;
            this.selectedType='';

            this.dateObject=datestr(thirtyDaysAgo(),'Local');

            this.newParamWanted=false;
            this.builtinParams=[{'Identifier','Used In'},this.userSubjects,this.dateSubjects];
            this.selectedParamIdx=0;
            this.selectedPredicateIdx=0;
            this.selectedValueIdx=0;
            this.textInputValue='';
            this.usedParamNames={};
            this.availableParamNames={};
            this.availablePredicates={};
            this.availableValues={};
            this.isEnumeratedValue=true;
            this.isDate=true;

            function defaultDate=thirtyDaysAgo()
                todayDate=datetime('Now');
                thirtyDays=hours(24*30);
                defaultDate=todayDate-thirtyDays;
            end
        end
    end

    methods

        function dlgstruct=getDialogSchema(this,~)

            topPanel.Type='group';

            if this.typeFilterIdx==0
                topPanel.Name=getString(message('Slvnv:slreq_import:SelectTypeOrParam'));
                topPanel.Items=makeTypeSelectorRow(this);
                nextRow=2;
            else
                topPanel.Name=getString(message('Slvnv:slreq_import:SpecifyQueryParams'));
                topPanel.LayoutGrid=[1,5];
                topPanel.Items={};
                nextRow=1;
            end


            if this.newParamWanted
                topPanel.Items=[topPanel.Items,makeFilterInputRow(this,nextRow)];
            else
                topPanel.Items=[topPanel.Items,makeNewFilterButtonRow(this,nextRow)];
            end
            topPanel.LayoutGrid=[nextRow,5];


            middlePanel.Type='group';
            middlePanel.Name=getString(message('Slvnv:slreq_import:ConfiguredFilters'));
            if~isempty(this.filterParts)
                [middlePanel.Items,rowCount]=this.displaySelectedParams();
                middlePanel.LayoutGrid=[rowCount,5];
            else
                noneText.Type='text';
                noneText.Name=getString(message('Slvnv:slreq_import:NoFiltersConfigured'));
                noneText.Tag='QueryDlg_noFilters';
                middlePanel.Items={noneText};
            end


            bottomPanel=this.makeRawQueryPanel();

            spacer.Type='text';
            spacer.Name=' ';
            spacer.Tag='QueryDlg_mainSpacer';

            dlgstruct.DialogTag='QueryDlg';
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:QueryBuilder'));
            dlgstruct.StandaloneButtonSet=this.setStandaloneButtons();
            dlgstruct.Items={topPanel,spacer,middlePanel,spacer,bottomPanel};
            dlgstruct.LayoutGrid=[6,1];
            dlgstruct.RowStretch=[0,0,0,0,0,1];
            dlgstruct.Geometry=[300,250,600,500];

            dlgstruct.CloseMethod='QueryDlg_Cancel_callback';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};

            dlgstruct.Sticky=true;
        end



        function out=setStandaloneButtons(this)

            okButton.Name=getString(message('Slvnv:slreq:OK'));
            okButton.Tag='QueryDlg_OK';
            okButton.Type='pushbutton';
            okButton.RowSpan=[1,1];
            okButton.ColSpan=[3,3];
            okButton.ObjectMethod='QueryDlg_OK_callback';
            okButton.MethodArgs={'%dialog'};
            okButton.ArgDataTypes={'handle'};
            okButton.Enabled=~isempty(this.queryString);

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='QueryDlg_Cancel';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[4,4];
            cancelButton.ObjectMethod='QueryDlg_Cancel_callback';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.Enabled=true;

            out.Tag='QueryDlg_standalonebuttons';
            out.LayoutGrid=[1,4];
            out.Name='';
            out.Type='panel';
            out.Items={okButton,cancelButton};
        end



        function typeSelectorRow=makeTypeSelectorRow(this)
            if isempty(this.types)

                this.types=this.QueryDlg_fetchTypes();
            end
            subjectLabel.Type='text';
            subjectLabel.Tag='QueryDlg_typeLabel';
            subjectLabel.Name='Object Type';
            subjectLabel.RowSpan=[1,1];
            subjectLabel.ColSpan=[1,1];

            typePredicate.Type='combobox';
            typePredicate.Tag='QueryDlg_typePredicate';
            typePredicate.Entries={'Is A','Is Not A'};
            typePredicate.Values=[0,1];
            typePredicate.Value=0;
            typePredicate.RowSpan=[1,1];
            typePredicate.ColSpan=[2,2];
            typePredicate.ObjectMethod='QueryDlg_typePredicate_callback';
            typePredicate.MethodArgs={'%dialog'};
            typePredicate.ArgDataTypes={'handle'};

            typeCombo.Type='combobox';
            typeCombo.Tag='QueryDlg_typeSelector';
            typeCombo.Entries=[{['<',getString(message('Slvnv:slreq_import:SelectSpecObjectType')),' >']},this.types];
            typeCombo.Values=0:numel(this.types);
            typeCombo.Value=this.selectedTypeIdx;
            typeCombo.RowSpan=[1,1];
            typeCombo.ColSpan=[3,4];
            typeCombo.ObjectMethod='QueryDlg_typeSelector_callback';
            typeCombo.MethodArgs={'%dialog'};
            typeCombo.ArgDataTypes={'handle'};

            queryByTypeButton.Name=getString(message('Slvnv:slreq_import:AddToQuery'));
            queryByTypeButton.Tag='QueryDlg_queryByType';
            queryByTypeButton.Type='pushbutton';
            queryByTypeButton.RowSpan=[1,1];
            queryByTypeButton.ColSpan=[5,5];
            queryByTypeButton.ObjectMethod='QueryDlg_queryByType_callback';
            queryByTypeButton.MethodArgs={'%dialog'};
            queryByTypeButton.ArgDataTypes={'handle'};
            queryByTypeButton.Enabled=(this.selectedTypeIdx>0);

            typeSelectorRow={subjectLabel,typePredicate,typeCombo,queryByTypeButton};
        end

        function[selectedParams,rowCount]=displaySelectedParams(this)
            selectedParams={};
            rowCount=0;
            for i=1:numel(this.filterParts)
                rowCount=rowCount+1;
                nextLabel.Type='text';
                nextLabel.Tag=sprintf('QueryDlg_filter%d',i);
                nextLabel.Name=this.filterParts{i};
                nextLabel.RowSpan=[rowCount,rowCount];
                nextLabel.ColSpan=[1,4];

                removeButton.Type='pushbutton';
                removeButton.Tag=sprintf('QueryDlg_removeFilter%d',i);
                removeButton.Name=getString(message('Slvnv:slreq_import:Remove'));
                removeButton.RowSpan=[rowCount,rowCount];
                removeButton.ColSpan=[5,5];
                removeButton.ObjectMethod='QueryDlg_removeFilter_callback';
                removeButton.MethodArgs={'%dialog',i};
                removeButton.ArgDataTypes={'handle','double'};

                selectedParams(end+1:end+2)={nextLabel,removeButton};
            end
        end

        function newParamButtonRow=makeNewFilterButtonRow(~,nextRow)

            spacer.Type='text';
            spacer.Name=' ';
            spacer.Tag='QueryDlg_spacer';
            spacer.ColSpan=[1,4];
            spacer.RowSpan=[nextRow,nextRow];

            newParamButton.Name=getString(message('Slvnv:slreq_import:AddFilter'));
            newParamButton.Tag='QueryDlg_addFilter';
            newParamButton.Type='pushbutton';
            newParamButton.RowSpan=[nextRow,nextRow];
            newParamButton.ColSpan=[5,5];
            newParamButton.ObjectMethod='QueryDlg_addFilter_callback';
            newParamButton.MethodArgs={'%dialog'};
            newParamButton.ArgDataTypes={'handle'};
            newParamButton.Enabled=true;

            newParamButtonRow={spacer,newParamButton};
        end

        function newParamRow=makeFilterInputRow(this,nextRow)
            paramNameCombo.Type='combobox';
            paramNameCombo.Tag='QueryDlg_paramName';
            if this.typeFilterIdx>0
                this.availableParamNames=[this.builtinParams,this.attributeNames];
            else
                this.availableParamNames=this.builtinParams;
            end
            paramNameCombo.Entries=[{['<',getString(message('Slvnv:slreq_import:SelectAttribute')),'>']},this.availableParamNames];
            paramNameCombo.Values=0:numel(this.availableParamNames);
            paramNameCombo.Value=this.selectedParamIdx;
            paramNameCombo.RowSpan=[nextRow,nextRow];
            paramNameCombo.ColSpan=[1,1];
            paramNameCombo.ObjectMethod='QueryDlg_paramName_callback';
            paramNameCombo.MethodArgs={'%dialog'};
            paramNameCombo.ArgDataTypes={'handle'};

            predicateCombo.Type='combobox';
            predicateCombo.Tag='QueryDlg_paramPredicate';
            predicateCombo.Enabled=(this.selectedParamIdx>0);
            predicateCombo.Entries=[{['<',getString(message('Slvnv:slreq_import:Select')),'>']},this.availablePredicates];
            predicateCombo.Values=0:numel(this.availablePredicates);
            predicateCombo.Value=this.selectedPredicateIdx;
            predicateCombo.RowSpan=[nextRow,nextRow];
            predicateCombo.ColSpan=[2,2];
            predicateCombo.ObjectMethod='QueryDlg_paramPredicate_callback';
            predicateCombo.MethodArgs={'%dialog'};
            predicateCombo.ArgDataTypes={'handle'};

            if this.isEnumeratedValue
                paramValue.Type='combobox';
                paramValue.Entries=[{['<',getString(message('Slvnv:slreq_import:Select')),'>']},this.availableValues];
                paramValue.Value=this.selectedValueIdx;
                paramValue.Values=0:numel(this.availableValues);
            else
                paramValue.Type='edit';
                paramValue.Value=this.textInputValue;
                if isempty(paramValue.Value)&&this.isDate
                    paramValue.Value=this.dateObject;
                end
            end
            paramValue.Tag='QueryDlg_paramValue';
            paramValue.RowSpan=[nextRow,nextRow];
            paramValue.ColSpan=[3,4];
            paramValue.ObjectMethod='QueryDlg_paramValue_callback';
            paramValue.MethodArgs={'%dialog'};
            paramValue.ArgDataTypes={'handle'};
            paramValue.Enabled=(this.selectedParamIdx>0)&&(this.selectedPredicateIdx>0);

            addToQueryButton.Type='pushbutton';
            addToQueryButton.Name=getString(message('Slvnv:slreq_import:AddToQuery'));
            addToQueryButton.Tag='QueryDlg_paramAddToQuery';
            addToQueryButton.RowSpan=[nextRow,nextRow];
            addToQueryButton.ColSpan=[5,5];
            addToQueryButton.ObjectMethod='QueryDlg_paramAddToQuery_callback';
            addToQueryButton.MethodArgs={'%dialog'};
            addToQueryButton.ArgDataTypes={'handle'};
            if this.isEnumeratedValue
                addToQueryButton.Enabled=(this.selectedParamIdx>0)&&(this.selectedPredicateIdx>0)&&(this.selectedValueIdx>0);
            else
                addToQueryButton.Enabled=(this.selectedParamIdx>0)&&(this.selectedPredicateIdx>0)&&~isempty(this.textInputValue);
            end
            newParamRow={paramNameCombo,predicateCombo,paramValue,addToQueryButton};
        end

        function queryDisplay=makeRawQueryPanel(this)

            queryDisplay.Type='group';
            queryDisplay.Name=getString(message('Slvnv:slreq_import:RawQueryString'));

            queryLabel.Type='text';
            queryLabel.Tag='QueryDlg_queryText';
            queryLabel.Name='Raw query string:';
            queryLabel.RowSpan=[1,1];
            queryLabel.ColSpan=[1,3];

            rawQueryButton.Type='pushbutton';
            rawQueryButton.Tag='QueryDlg_showRawQuery';
            rawQueryButton.RowSpan=[1,1];
            rawQueryButton.ColSpan=[4,4];
            rawQueryButton.ObjectMethod='QueryDlg_showRawQuery_callback';
            rawQueryButton.MethodArgs={'%dialog'};
            rawQueryButton.ArgDataTypes={'handle'};
            rawQueryButton.Enabled=~isempty(this.queryParts);

            if this.showRawQuery
                rawQueryButton.Name=getString(message('Slvnv:slreq_import:Hide'));

                queryValue.Type='listbox';
                queryValue.Tag='QueryDlg_query';
                queryValue.Name='';
                queryValue.Entries=this.queryParts;
                queryValue.RowSpan=[2,2];
                queryValue.ColSpan=[1,4];

                queryDisplay.Items={queryLabel,rawQueryButton,queryValue};
                queryDisplay.LayoutGrid=[2,4];
            else
                rawQueryButton.Name=getString(message('Slvnv:slreq_import:Show'));

                queryDisplay.Items={queryLabel,rawQueryButton};
                queryDisplay.LayoutGrid=[1,4];
            end
        end



        function QueryDlg_showRawQuery_callback(this,dlg)
            this.showRawQuery=~this.showRawQuery;
            dlg.refresh();
        end

        function QueryDlg_addFilter_callback(this,dlg)
            this.selectedParamIdx=0;
            this.selectedPredicateIdx=0;
            this.selectedValueIdx=0;
            this.newParamWanted=true;
            dlg.refresh();
        end

        function QueryDlg_paramName_callback(this,dlg)
            this.selectedParamIdx=dlg.getWidgetValue('QueryDlg_paramName');
            paramName=this.availableParamNames{this.selectedParamIdx};
            this.isEnumeratedValue=false;
            this.isDate=false;
            switch(paramName)
            case 'Identifier'
                this.availablePredicates={'equal','is one of'};
            case this.userSubjects
                this.availablePredicates={'equal','not equal'};
            case this.dateSubjects
                this.availablePredicates={'before','after'};
                this.isDate=true;
            otherwise
                this.isEnumeratedValue=true;
                this.availablePredicates={'equal','not equal'};
            end
            dlg.refresh();
        end

        function QueryDlg_paramPredicate_callback(this,dlg)
            this.selectedPredicateIdx=dlg.getWidgetValue('QueryDlg_paramPredicate');
            if this.isEnumeratedValue
                this.availableValues=this.getAvailableValues();
            else
                this.availableValues={};
            end
            dlg.refresh();
        end

        function QueryDlg_paramValue_callback(this,dlg)
            if this.isEnumeratedValue
                this.selectedValueIdx=dlg.getWidgetValue('QueryDlg_paramValue');
                this.textInputValue='';
            else
                this.selectedValueIdx=0;
                this.textInputValue=dlg.getWidgetValue('QueryDlg_paramValue');
            end
            dlg.refresh();
        end

        function QueryDlg_paramAddToQuery_callback(this,dlg)
            paramName=this.availableParamNames{this.selectedParamIdx};
            paramPredicate=this.availablePredicates{this.selectedPredicateIdx};
            if this.isEnumeratedValue
                paramValue=this.availableValues{this.selectedValueIdx};
            else
                paramValue=this.textInputValue;
            end
            [newQueryPart,note]=this.makeQueryPart(paramName,paramPredicate,paramValue);
            if~isempty(newQueryPart)
                this.updateQueryParts(newQueryPart,note,this.isEnumeratedValue);
                this.usedParamNames{end+1}=paramName;
                this.newParamWanted=false;
                dlg.refresh();
            end
        end

        function QueryDlg_typeSelector_callback(this,dlg)
            this.attributeNames={};
            this.attributeValues={};
            idx=dlg.getWidgetValue('QueryDlg_typeSelector');
            this.selectedTypeIdx=idx;
            if idx==0

                this.selectedType='';
                this.typeIsSelected=false;
            else
                this.selectedType=this.types{idx};
                specObjectType=this.findSpecObjectTypeByName(this.selectedType);
                if~isempty(specObjectType)
                    specAttributes=specObjectType.specAttributes.toArray();
                    for i=1:length(specAttributes)
                        specAttribute=specAttributes(i);
                        this.attributeNames{end+1}=specAttribute.longName;
                    end
                end
                this.typeIsSelected=(dlg.getWidgetValue('QueryDlg_typePredicate')==0);
            end
            dlg.refresh();
        end

        function QueryDlg_typePredicate_callback(this,dlg)
            value=dlg.getWidgetValue('QueryDlg_typePredicate');
            this.typeIsSelected=(value==0)&&(this.selectedTypeIdx>0);
            dlg.refresh();
        end

        function QueryDlg_queryByType_callback(this,dlg)

            idx=dlg.getWidgetValue('QueryDlg_typeSelector');
            this.selectedType=this.types{idx};
            specObjectType=this.findSpecObjectTypeByName(this.selectedType);

            typeUri=specObjectType.identifier;
            wrappedValue=urlencode(sprintf('<%s>',typeUri));
            if dlg.getWidgetValue('QueryDlg_typePredicate')==0
                newQueryString=sprintf('rm:ofType=%s',wrappedValue);
                note=sprintf('Item type IS A %s',this.selectedType);
            else
                newQueryString=sprintf('rm:ofType!=%s',wrappedValue);
                note=sprintf('Item type IS NOT A %s',this.selectedType);
            end
            this.updateQueryParts(newQueryString,note,false);
            dlg.refresh();
        end

        function QueryDlg_removeFilter_callback(this,dlg,idxToRemove)
            if idxToRemove==this.typeFilterIdx

                allIdxToRemove=this.partIsTypeDependent;
                allIdxToRemove(this.typeFilterIdx)=true;
                this.queryParts(allIdxToRemove)=[];
                this.filterParts(allIdxToRemove)=[];
                this.partIsTypeDependent(allIdxToRemove)=[];
                this.typeFilterIdx=0;
            else

                this.queryParts(idxToRemove)=[];
                this.filterParts(idxToRemove)=[];
                this.partIsTypeDependent(idxToRemove)=[];
            end

            this.updateQueryString();
            dlg.refresh();
        end


        function QueryDlg_OK_callback(this,~)

            this.caller.getSource.setOslcOptionsFromQueryBuilderDialog(this,true);
            slreq.import.ui.attrDlg_mgr('clear');
        end


        function QueryDlg_Cancel_callback(this,~)
            this.caller.getSource.setOslcOptionsFromQueryBuilderDialog(this,false);
            slreq.import.ui.attrDlg_mgr('clear');
        end



        function[newQueryString,note]=makeQueryPart(this,paramName,paramPredicate,paramValue)




            newQueryString='';
            note='';

            switch paramPredicate

            case 'equal'
                predicate='=';
            case 'not equal'
                predicate='!=';
            case 'is one of'
                predicate=' in ';
                if any(paramValue==',')
                    paramValue=regexprep(paramValue,' ','');
                else
                    paramValue=strtrim(paramValue);
                    paramValue=regexprep(paramValue,' +',',');
                end
                paramValue=sprintf('[%s]',paramValue);

            case 'before'
                predicate='<';
            case 'after'
                predicate='>';

            otherwise

                errordlg(paramPridicate,'Unsupported Predicate');
                return;
            end

            switch paramName
            case 'Identifier'
                newQueryString=['dcterms:identifier',predicate,paramValue];
                note=sprintf('%s %s %s',paramName,paramPredicate,paramValue);

            case this.userSubjects
                if strcmp(paramName,'CreatedBy')
                    subject='creator';
                else
                    subject='contributor';
                end
                serverUrl=oslc.server();
                userUri=sprintf('%s/jts/users/%s',serverUrl,paramValue);
                wrappedUserUri=sprintf('<%s>',userUri);
                newQueryString=sprintf('dcterms:%s%s%s',subject,predicate,wrappedUserUri);
                note=sprintf('%s %s %s',subject,predicate,paramValue);

            case this.dateSubjects
                if strcmp(paramName,'CreatedOn')
                    subject='created';
                else
                    subject='modified';
                end
                dt=datetime(paramValue);

                isodate=datestr(dt,'yyyy-mm-ddTHH:MM:SS');
                valueForQuery=['"',isodate,'"^^xsd:DateTime'];
                newQueryString=sprintf('dcterms:%s%s%s',subject,predicate,valueForQuery);
                note=sprintf('%s %s %s',paramName,paramPredicate,paramValue);

            otherwise


                [newQueryString,note]=this.attributeValueQuery(paramName,predicate,paramValue);
            end
        end

        function[newQueryString,note]=attributeValueQuery(this,attributeName,predicate,attributeValue)
            newQueryString='';
            note='';
            specObjectType=this.findSpecObjectTypeByName(this.selectedType);
            if isempty(specObjectType)
                rmiut.warnNoBacktrace('ERROR: failed to identify Type by name: %s',this.selectedType);
                return;
            end

            foundAttribute=this.findAttributeByName(specObjectType,attributeName);
            if isempty(specObjectType)

                rmiut.warnNoBacktrace('ERROR: failed to find name %s in %s',attributeName,this.selectedType);
                return;
            end
            attributeURI=foundAttribute.identifier;

            valueURI='';
            enumValues=foundAttribute.type.specifiedValues.toArray();
            for i=1:length(enumValues)
                enumValue=enumValues(i);
                if strcmp(enumValue.longName,attributeValue)
                    valueURI=enumValue.identifier;
                    break;
                end
            end
            if isempty(valueURI)

                rmiut.warnNoBacktrace('ERROR: failed to find valueURI for %s in %s',this.selectedAttributeValue,this.selectedAttributeName);
                return;
            end

            wrappedValue=urlencode(sprintf('<%s>',valueURI));
            newQueryString=sprintf('rm_property:%s%s%s',attributeURI,predicate,wrappedValue);
            note=sprintf('%s %s %s',attributeName,predicate,attributeValue);
        end

        function attributeValues=getAvailableValues(this)
            attributeValues={};
            specObjectType=this.findSpecObjectTypeByName(this.selectedType);
            if~isempty(specObjectType)
                attributeName=this.availableParamNames{this.selectedParamIdx};
                foundAttribute=this.findAttributeByName(specObjectType,attributeName);
                if~isempty(foundAttribute)
                    enumValues=foundAttribute.type.specifiedValues.toArray();
                    for i=1:length(enumValues)
                        attributeValues{end+1}=enumValues(i).longName;%#ok<AGROW>
                    end
                end
            end
        end

        function types=QueryDlg_fetchTypes(this)

            types={};
            try



                reqData=slreq.data.ReqData.getInstance();
                this.reqIf=reqData.fetchOSLCProjectTypes(this.serverLoginInfo,this.serverLoginInfo.uri);
                specTypes=this.reqIf.coreContent.specTypes.toArray();
                for i=1:length(specTypes)
                    specType=specTypes(i);
                    if isa(specType,'slreq.reqif.SpecObjectType')
                        types{end+1}=specType.longName;%#ok<AGROW>
                    end
                end
            catch ex
                rmiut.warnNoBacktrace(ex.message);
            end
        end

        function out=findSpecObjectTypeByName(this,name)
            out=[];
            if~isempty(this.reqIf)
                specTypes=this.reqIf.coreContent.specTypes.toArray();
                for i=1:length(specTypes)
                    specAttribute=specTypes(i);
                    if isa(specAttribute,'slreq.reqif.SpecObjectType')&&...
                        strcmp(specAttribute.longName,name)
                        out=specAttribute;
                        break;
                    end
                end
            else


                rmiut.warnNoBacktrace('findSpecObjectTypeByName(): this.reqIf is unassigned!');
            end
        end

        function out=findAttributeByName(~,specObjectType,name)
            out=[];
            specAttributes=specObjectType.specAttributes.toArray();
            for i=1:length(specAttributes)
                specAttribute=specAttributes(i);

                if strcmp(specAttribute.longName,name)
                    out=specAttribute;
                    break;
                end
            end
        end

        function updateQueryParts(this,value,note,isTypeDependent)


            this.queryParts{end+1}=value;
            this.partIsTypeDependent(end+1)=isTypeDependent;
            this.filterParts{end+1}=note;


            if contains(value,'rm:ofType=')
                this.typeFilterIdx=numel(this.filterParts);
            end


            this.updateQueryString();
        end

        function updateQueryString(this)
            if isempty(this.queryParts)
                this.queryString='';
            else

                this.queryString=this.queryParts{end};






            end
        end
    end
end
