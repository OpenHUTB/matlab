


classdef CScriptPortSS<handle
    properties(SetAccess=private,GetAccess=public)
        m_Children;
        m_DialogSource;
        m_PortSpecHandle;
        m_UpdateCells;
    end


    methods
        function aChildren=getChildren(this)
            aChildren=this.m_Children;
        end
    end


    methods
        function this=CScriptPortSS(portSpecCScript)
            import SLCC.blocks.ui.PortSpec.*;
            import SLCC.blocks.*;

            this.m_PortSpecHandle=portSpecCScript;
            this.m_Children=CScriptPortSSRow.empty;
        end

        function setDialogSrc(this,hDlgSrc)
            this.m_DialogSource=hDlgSrc;
        end

        function hDlgSrc=getDialogSrc(this)
            hDlgSrc=this.m_DialogSource;
        end

        function setUpdatedCells(this,affectedUITableCells)
            this.m_UpdateCells=affectedUITableCells;
        end

        function affectedUITableCells=getUpdatedCells(this)
            affectedUITableCells=this.m_UpdateCells;
        end

        function clearUpdatedCells(this)
            this.m_UpdateCells=[];
        end

        function updateSpreadsheet(this)



            import SLCC.blocks.ui.PortSpec.*;
            hBlock=get(this.m_DialogSource.getBlock,'Handle');
            obj=get_param(hBlock,'SymbolSpec');
            portStruct=obj.getAllSymbols;
            symbolOrder={portStruct.Name};
            numChildNew=numel(portStruct);
            numChildOld=numel(this.m_Children);
            numToRefresh=min(numChildOld,numChildNew);

            portHeuristicStruct=getPortHeuristicStruct(this,portStruct);

            updatedCells=getUpdatedCells(this);


            if~isempty(updatedCells)
                switch(updatedCells.Method)
                case{'SetSymbolName'}
                    childIdx=find(strcmp(symbolOrder,updatedCells.SymbolName));
                    this.m_Children(childIdx).refreshCellOnPortStruct(updatedCells.SymbolName,updatedCells.Method);
                    updateLabel=this.m_Children(childIdx).updateLabelOnUI(obj.getSymbol(updatedCells.SymbolName).Scope,...
                    obj.getSymbol(updatedCells.SymbolName).Label);
                    this.m_Children(childIdx).refreshCellOnPortStruct(updateLabel,'SetSymbolLabel');
                case{'SetSymbolSize'}
                    childIdx=find(strcmp(symbolOrder,updatedCells.SymbolName));
                    this.m_Children(childIdx).refreshCellOnPortStruct(obj.getSymbol(updatedCells.SymbolName).Size,updatedCells.Method);
                case{'SetSymbolLabel'}
                    childIdx=find(strcmp(symbolOrder,updatedCells.SymbolName));
                    this.m_Children(childIdx).refreshCellOnPortStruct(obj.getSymbol(updatedCells.SymbolName).Label,updatedCells.Method);
                case{'SetSymbolType'}
                    childIdx=find(strcmp(symbolOrder,updatedCells.SymbolName));
                    this.m_Children(childIdx).refreshCellOnPortStruct(obj.getSymbol(updatedCells.SymbolName).Type,updatedCells.Method);
                    if portHeuristicStruct(childIdx).isSizeEditable~=this.m_Children(childIdx).m_SizeEditable
                        this.m_Children(childIdx).refreshCellOnPortStruct(obj.getSymbol(updatedCells.SymbolName).Size,'SetSymbolSize');
                        this.m_Children(childIdx).refreshCellOnPortStruct(portHeuristicStruct(childIdx).isSizeEditable,'SetSizeEditable');
                    end
                case{'SetSymbolScope','SetSymbolIndex'}
                    for n=1:numToRefresh
                        this.m_Children(n).refreshFromPortStruct(portStruct(n),...
                        portHeuristicStruct(n));
                    end
                case{'AddSymbol'}

                    if isempty(this.m_Children)

                        this.m_Children(1)=CScriptPortSSRow.constructFromPortStruct(...
                        this,portStruct(1),portHeuristicStruct(1));
                    else
                        this.m_Children(end+1)=CScriptPortSSRow.constructFromPortStruct(...
                        this,portStruct(numChildNew),portHeuristicStruct(numChildNew));
                        for n=1:numToRefresh
                            if strcmp(portStruct(n).Scope,portStruct(numChildNew).Scope)
                                this.m_Children(n).refreshCellOnPortStruct(portHeuristicStruct(n).validIndexValues,updatedCells.Method);
                            end
                        end
                    end
                case{'RemoveSymbol'}
                    for n=1:numToRefresh
                        this.m_Children(n).refreshFromPortStruct(portStruct(n),...
                        portHeuristicStruct(n));
                    end
                    delete(this.m_Children(end));
                    this.m_Children(end)=[];
                otherwise
                    error([updatedCells.Method,' is not a valid method action.']);
                end
            else



                for n=1:numChildNew
                    this.m_Children(n)=CScriptPortSSRow.constructFromPortStruct(...
                    this,portStruct(n),portHeuristicStruct(n));
                end
            end

            clearUpdatedCells(this);
        end

        function updateSSWidget(this,affectedUITableCells)
            setUpdatedCells(this,affectedUITableCells);
            if isa(this.m_DialogSource,'Simulink.SLDialogSource')
                dlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DialogSource);
                for n=1:numel(dlgs)
                    d=dlgs(n);
                    if~isempty(d)


                        switch(affectedUITableCells.Method)

                        case{'SetSymbolScope','SetSymbolIndex','RemoveSymbol'}
                            d.refreshWidget('csb_portSpec_spreadsheet_tag');
                        case{'SetSymbolName','SetSymbolLabel','SetSymbolSize','SetSymbolType','AddSymbol'}

                        otherwise
                            error([affectedUITableCells.Method,' is not a valid method action.']);
                        end
                        d.refresh();
                    end
                end



                if isempty(dlgs)&&~isempty(this.m_DialogSource)
                    updateSpreadsheet(this);
                end
            end
        end

        function portOptions=getPortHeuristicStruct(this,portSpecStruct)
            portOptions=struct;
            validScopeSet={'Input','Output','InputOutput','Parameter','Persistent','Constant'};
            validTypeMap=this.getValidTypeForPortOptions(validScopeSet);
            validIndexMap=this.getValidIndexForPortOptions(portSpecStruct,validScopeSet);
            for i=1:numel(portSpecStruct)
                portOptions(i).isNameEditable=true;
                portOptions(i).isScopeEditable=true;
                portOptions(i).isLabelEditable=true;
                portOptions(i).isTypeEditable=true;
                portOptions(i).isSizeEditable=this.getSizeEditable(portSpecStruct(i));
                portOptions(i).validTypeValues=validTypeMap(portSpecStruct(i).Scope);
                portOptions(i).validScopeValues=validScopeSet;
                switch(portSpecStruct(i).Scope)
                case{'Persistent'}
                    portOptions(i).isIndexEditable=false;
                    portOptions(i).validIndexValues={'-'};
                    portOptions(i).isLabelEditable=false;
                case{'Constant'}
                    portOptions(i).isIndexEditable=false;
                    portOptions(i).validIndexValues={'-'};
                case{'Input','Output','InputOutput','Parameter'}
                    portOptions(i).isIndexEditable=true;
                    portOptions(i).validIndexValues=validIndexMap(portSpecStruct(i).Scope);
                otherwise
                    error([portSpecStruct(i).Scope,' is not a valid scope name.']);
                end
            end
        end

        function isEditable=getSizeEditable(~,symStruct)
            switch(symStruct.Scope)
            case 'Constant'
                isEditable=false;
            case 'Persistent'
                isEditable=~strcmpi(symStruct.Type,'VoidPointer')&&...
                isempty(regexp(symStruct.Type,'^[Cc]lass:\s*(.*)','once'));
            otherwise
                isEditable=true;
            end
        end

        function validIndexMap=getValidIndexForPortOptions(~,portSpecStruct,validScopeSet)
            validIndexSet=cell(1,length(validScopeSet));
            totScopePorts=zeros(1,length(validScopeSet));
            startIndexSet=zeros(1,length(validScopeSet));
            for i=1:numel(portSpecStruct)
                idx=find(strcmp(validScopeSet,portSpecStruct(i).Scope),1);
                totScopePorts(idx)=totScopePorts(idx)+1;
            end
            idx=find(strcmp(validScopeSet,'InputOutput'),1);
            totInOutPorts=totScopePorts(idx);
            for i=1:length(validIndexSet)
                switch(validScopeSet{i})
                case{'Input','Output'}
                    startIndexSet(i)=1+totInOutPorts;
                otherwise
                    startIndexSet(i)=1;
                end
            end
            for i=1:length(validIndexSet)
                if totScopePorts(i)~=0
                    validIndexSet{i}=strtrim(cellstr(num2str([startIndexSet(i):startIndexSet(i)-1+totScopePorts(i)]')));
                else
                    validIndexSet{i}=strtrim(cellstr(num2str(totScopePorts(i))));
                end
            end
            validIndexMap=containers.Map(validScopeSet,validIndexSet);
        end

        function validTypeMap=getValidTypeForPortOptions(this,validScopeSet)
            validTypeSet=cell(1,length(validScopeSet));
            hBlock=get(this.m_DialogSource.getBlock,'Handle');
            hMdl=bdroot(hBlock);
            [slDTypeList,~]=slprivate('slGetUserDataTypesFromWSDD',get_param(hBlock,'Object'),[],[],true);
            classType=slcc('getClassTypesVisibleToModel',hMdl);
            for i=1:length(validScopeSet)
                switch(validScopeSet{i})
                case{'Input','Output','InputOutput','Parameter'}
                    validTypeSet{i}=[Simulink.DataTypePrmWidget.getBuiltinList('NumBool');...
                    slDTypeList';{'Enum: <class name>';'Bus: <object name>'}];
                case{'Constant'}
                    validTypeSet{i}=[Simulink.DataTypePrmWidget.getBuiltinList('NumBool')];
                case{'Persistent'}
                    validTypeSet{i}=[Simulink.DataTypePrmWidget.getBuiltinList('NumBool');...
                    slDTypeList';{'Enum: <class name>';'Bus: <object name>';'VoidPointer'};classType];
                otherwise
                    error([validScopeSet{i},' is not a valid scope name.']);
                end
            end
            validTypeMap=containers.Map(validScopeSet,validTypeSet);
        end

        function tf=isDragAllowed(this)%#ok<MANU>
            tf=true;
        end

        function typeSet=filterInvalidTypes(this,typeSet,invalidTypes)
            typeSet(contains(typeSet,invalidTypes))=[];
        end

    end
end

