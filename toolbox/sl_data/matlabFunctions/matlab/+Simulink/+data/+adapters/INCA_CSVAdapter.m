classdef INCA_CSVAdapter<Simulink.data.adapters.BaseMatlabFileAdapter




    properties
    end

    methods

        function adapterName=getAdapterName(~)
            adapterName='INCA_CSVAdapter';
        end

        function sections=getSectionNames(~,~)
            sections={'ValueSrc'};
        end


        function extensions=getSupportedExtensions(~)

            extensions={'.csv'};
        end


        function retVal=supportsReading(this,Source)
            retVal=false;
            if this.isSourceValid(Source)
                retVal=true;
            end
        end


        function retVal=supportsWriting(~,~)
            retVal=false;
        end


        function diagnostic=getData(this,sourceWorkspace,~,diagnostic)


            try
                structOutput=INCA_CSV_parser(this.source);

                setVariables(sourceWorkspace,{structOutput.Name},{structOutput.tableValue});
            catch ME
                clearAllVariables(sourceWorkspace);
                diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                diagnostic.DiagnosticMessage=[this.getAdapterName(),': reports ',ME.message];
            end
        end


        function diagnostic=writeData(~,~,~,diagnostic)
            assert(false,'Writing INCACSV files is not currently supported')
        end


    end
end

function structOutput=INCA_CSV_parser(filename)
    raw=fileread(filename);

    rawArr=split(raw,newline);
    nRows=numel(rawArr);


    state='ReadName';

    structOutput=struct();
    kk=0;

    r=1;
    while r<=nRows

        if isempty(rawArr{r})||lIsEmptyRow(rawArr{r})
            r=r+1;
            continue;
        end


        switch state
        case 'ReadName'
            rr=split(rawArr{r},',');

            kk=kk+1;
            structOutput(kk).Name=rr{2};

            r=r+1;
            state='ReadType';

        case 'ReadType'
            rr=split(rawArr{r},',');

            type=rr{1};

            switch type
            case 'VALUE'
                structOutput(kk).Dimension=0;
                structOutput(kk).Axis=false;

                state='ReadValue';

            case 'MAP'
                structOutput(kk).Dimension=2;
                structOutput(kk).Axis=false;

                r=r+2;
                state='ReadMap';

            case 'CURVE'
                structOutput(kk).Dimension=1;
                structOutput(kk).Axis=false;

                r=r+1;
                state='ReadCurve';

            case{'Y_AXIS_PTS','X_AXIS_PTS','AXIS_PTS'}

                structOutput(kk).Dimension=1;
                structOutput(kk).Axis=true;

                state='ReadAxisPts';

            otherwise
                msg=['error parsing ',filename,', line: ',num2str(r)];
                error(msg);
            end

        case 'ReadValue'
            rr=split(rawArr{r},',');
            structOutput(kk).tableValue=str2double(rr{3});


            r=r+1;
            state='ReadName';

        case 'ReadMap'
            structOutput(kk).Dimension=2;
            structOutput(kk).Axis=false;

            mapValue=[];
            while~lIsEmptyRow(rawArr{r})
                trimmedData=strtrim(rawArr{r});
                rowData=split(trimmedData,',')';
                rowDataDouble=str2double(rowData);
                nanStatus=~isnan(rowDataDouble);
                singleRowValue=rowDataDouble(nanStatus);
                mapValue=[mapValue;singleRowValue];%#ok
                r=r+1;
            end
            structOutput(kk).tableValue=mapValue;


            r=r+1;
            state='ReadName';

        case{'ReadCurve','ReadAxisPts'}
            trimmedData=strtrim(rawArr{r});
            rowData=split(trimmedData,',')';
            rowDataDouble=str2double(rowData);
            nanStatus=~isnan(rowDataDouble);
            structOutput(kk).tableValue=rowDataDouble(nanStatus);


            r=r+1;
            state='ReadName';

        case 'otherwise'
            msg=['error parsing ',filename,', line: ',num2str(r)];
            error(msg);
        end
    end


end


function retVal=lIsEmptyRow(rowData)
    retVal=true;
    if isempty(rowData)
        return;
    end
    rowData=strtrim(rowData);
    splittedRow=split(rowData,',')';
    emptyStatus=~cellfun(@isempty,splittedRow);
    retVal=~any(emptyStatus);
end


