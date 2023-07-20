function addTargetFunctionLibrary(lTargetRegistry,srcTFL,varargin)

















    newTFL=srcTFL.getcopy;


    refreshCRL(lTargetRegistry);

    if nargin<3
        mode='check';
    elseif nargin==3
        mode=varargin{1};
    else
        DAStudio.error('RTW:targetRegistry:invalidNumInput');
    end

    switch mode
    case 'check'
        if~isa(newTFL,'RTW.TflRegistry')
            DAStudio.error('RTW:targetRegistry:invalidTFL');
        end

        if isempty(newTFL.Name)
            DAStudio.error('RTW:targetRegistry:emptyCRLName');
        elseif contains(newTFL.Name,',')
            DAStudio.error('RTW:tfl:invalidTflRegistryName',newTFL.Name);
        end

        if~isempty(newTFL.Alias)&&ismember('',newTFL.Alias)
            DAStudio.error('RTW:targetRegistry:emptyAlias');
        elseif~isempty(newTFL.Alias)&&ismember(',',newTFL.Alias)
            DAStudio.error('RTW:tfl:invalidTflRegistryAlias',newTFL.Alias);
        end



        newNAName=get(newTFL,'Name');
        newNAAlias=get(newTFL,'Alias');
        existingNA=get(lTargetRegistry.TargetFunctionLibraries,{'Name','Alias'});

        existingNAName={};
        existingNAAlias={};
        if~isempty(existingNA)
            existingNAName=existingNA(:,1);
            existingNAAlias=existingNA(:,2);
        end
        tmp={};
        for i=1:length(existingNAAlias)
            tmp=[tmp(:);existingNAAlias{i,:}];
        end
        updateTfl=intersect([newNAName;newNAAlias(:)],[existingNAName(:);tmp]);

        if~isempty(updateTfl)

            updateTfl=coder.internal.getTfl(lTargetRegistry,updateTfl{1});


            if~isempty(newTFL.BaseTfl)

                if isempty(updateTfl.BaseTfl)||(~isempty(updateTfl.BaseTfl)&&...
                    ~strcmp(coder.internal.getTfl(lTargetRegistry,newTFL.BaseTfl).Name,coder.internal.getTfl(lTargetRegistry,updateTfl.BaseTfl).Name))
                    DAStudio.error('RTW:targetRegistry:incompatibleBaseTfl',newTFL.BaseTfl);
                end
            end





            updateTfl.TableList=...
            RTW.unique({updateTfl.TableList{:},newTFL.TableList{:}});%#ok<*CCAT>
            updateTfl.TargetCharacteristics.DataAlignment=coder.internal.updateDataAlignInfo(...
            lTargetRegistry,updateTfl.TargetCharacteristics.DataAlignment...
            ,newTFL.TargetCharacteristics.DataAlignment);
        else
            appendTargetFunctionLibrary(lTargetRegistry,newTFL);
        end

    case 'nocheck'
        appendTargetFunctionLibrary(lTargetRegistry,newTFL);
    otherwise
        DAStudio.error('RTW:targetRegistry:unexpectedMode',mode,'check or nocheck');
    end





