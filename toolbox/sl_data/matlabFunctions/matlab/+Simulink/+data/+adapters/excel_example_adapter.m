classdef excel_example_adapter<Simulink.data.adapters.BaseMatlabFileAdapter





    methods
        function name=getAdapterName(~)
            name='Excel Example Adapter';
        end

        function extensions=getSupportedExtensions(~)
            extensions={'.xls','.xlsx'};
        end

        function sections=getSectionNames(this,Source)
            sections=cellstr(sheetnames(Source)');
            removedCounter=0;
            for iter=1:numel(sections)
                if~this.checkHeader(Source,sections{iter-removedCounter})
                    sections(iter-removedCounter)=[];
                    removedCounter=removedCounter+1;
                end
            end
        end

        function canParse=checkHeader(~,fileName,section)
            canParse=false;
            data=readcell(fileName,'Range','A1:B3','Sheet',section);

            if(strcmpi(data{1,1},'MATHWORKS EXAMPLE DATA')&&...
                strcmpi(data{2,1},'SPREADSHEET FORMAT VERSION 1.0')&&...
                strcmpi(data{3,1},'name')&&strcmpi(data{3,2},'value'))
                canParse=true;
            end

        end

        function retVal=supportsReading(this,Source)
            retVal=false;

            if supportsReading@Simulink.data.adapters.BaseMatlabFileAdapter(this,Source)&&...
                0<numel(this.getSectionNames(Source))
                retVal=true;
            end
        end

        function retVal=supportsWriting(~,~)
            retVal=false;
        end

        function retVal=isEmptyRow(~,raw,row,colSize)
            for i=1:colSize
                if~any(ismissing(raw{row,i}))
                    retVal=false;
                    return
                end
            end
            retVal=true;
        end


        function retVal=getMaxtrixRowSize(~,raw,row,colSize)
            retVal=colSize;
            for i=2:colSize
                if any(ismissing(raw{row,i}))
                    retVal=i-1;
                    return
                end
            end
        end


        function retVal=getMaxtrixColSize(~,raw,row,rowSize)
            retVal=row;
            for i=row+1:rowSize

                if~any(ismissing(raw{i,1}))||any(ismissing(raw{i,2}))
                    retVal=i-1;
                    return
                end
                retVal=i;
            end
        end



        function retVal=getMatrix(~,raw,x,y,xEnd,yEnd)
            rowSize=xEnd-x+1;
            colSize=yEnd-y+1;
            retVal=zeros(rowSize,colSize);
            for i=x:xEnd
                for j=y:yEnd
                    retVal(i-x+1,j-y+1)=raw{i,j};
                end
            end
        end

        function diagnostic=getData(this,sourceWorkspace,~,diagnostic)
            clearAllVariables(sourceWorkspace);
            if~this.checkHeader(this.source,this.section)
                diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                diagnostic.DiagnosticMessage='Header format is incorrect';
            end

            raw=readcell(this.source,'Sheet',this.section,'Range','A4');
            [nRows,nCols]=size(raw);

            iter=1;
            while iter<=nRows
                if this.isEmptyRow(raw,iter,nCols)

                    iter=iter+1;
                    continue
                end

                if any(ismissing(raw{iter,1}))

                    clearAllVariables(sourceWorkspace);
                    diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                    diagnostic.DiagnosticMessage=['Bad data in row ',num2str(iter)];
                    return;
                end

                if~isvarname(raw{iter,1})
                    clearAllVariables(sourceWorkspace);
                    diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                    diagnostic.DiagnosticMessage=['Invalid variable name in row ',num2str(iter)];
                    return;
                end
                name=raw{iter,1};

                colEnd=this.getMaxtrixRowSize(raw,iter,nCols);
                rowEnd=this.getMaxtrixColSize(raw,iter,nRows);

                value=this.getMatrix(raw,iter,2,rowEnd,colEnd);
                setVariable(sourceWorkspace,name,value);
                iter=rowEnd+1;
            end

        end

        function diagnostic=writeData(~,~,~,diagnostic)
            diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.Unsupported;
            diagnostic.DiagnosticMessage='Unsupported';
        end

    end
end
