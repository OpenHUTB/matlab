classdef EditRegisterTableDDG<handle



    properties
blkH
blkP
tabIdx
tabR
pMap
    end
    properties(Constant)
        NUMCOLS=4;
    end
    methods
        function this=EditRegisterTableDDG(blkH,tabIdx)
            this.blkH=blkH;
            this.blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
            this.pMap=containers.Map((1:this.NUMCOLS),{'RegTableNames','RegTableRW','RegTableDataTypes','RegTableVectorSizes'});
            this.tabIdx=tabIdx;
            this.tabR=this.getTableParams();
        end

        function dlg=getDialogSchema(this,~)
            dlg.DialogTitle=['Editing Register: ',this.tabR.(this.pMap(1))];

            regTableNameEdit.Name='Register name:';
            regTableNameEdit.Type='edit';
            regTableNameEdit.Value=this.tabR.(this.pMap(1));
            regTableNameEdit.Tag='RegTableNames';

            regTableDirectionComboBox.Type='combobox';
            regTableDirectionComboBox.Name='Direction:        ';
            regTableDirectionComboBox.Entries={'Read','Write'};
            regTableDirectionComboBox.Value=this.tabR.(this.pMap(2));
            regTableDirectionComboBox.Tag='RegTableRW';

            regTableDatatypeComboBox.Type='combobox';
            regTableDatatypeComboBox.Name='Data type:      ';
            regTableDatatypeComboBox.Editable=true;
            regTableDatatypeComboBox.Entries=this.getSupportedTypes();
            regTableDatatypeComboBox.Value=this.tabR.(this.pMap(3));
            regTableDatatypeComboBox.Tag='RegTableDataTypes';

            regTableDimensionEdit.Name='Vector size:     ';
            regTableDimensionEdit.Type='edit';
            regTableDimensionEdit.Value=this.tabR.(this.pMap(4));
            regTableDimensionEdit.Tag='RegTableVectorSizes';

            dlg.Items={...
            regTableNameEdit,...
            regTableDirectionComboBox,...
            regTableDatatypeComboBox,...
regTableDimensionEdit
            };
            dlg.Sticky=true;
            dlg.LayoutGrid=[4,1];



            dlg.PreApplyMethod='preApplyCb';
            dlg.PreApplyArgs={'%dialog'};
            dlg.PreApplyArgsDT={'handle'};
        end

        function[ret,errMsg]=preApplyCb(this,dlg)
            ret=true;
            errMsg=[];


            dlg.setTitle(['Editing Register: ',this.blkP.(this.pMap(1)){this.tabIdx}]);


            maskObj=Simulink.Mask.get(this.blkH);
            tabC=maskObj.getDialogControl('RegisterTable');

            for i=1:this.NUMCOLS
                col=this.pMap(i);
                if i==2
                    val=dlg.getComboBoxText(col);
                else
                    val=dlg.getWidgetValue(col);
                    try
                        validateTableParams(this,tabC,i,val);
                    catch ex
                        errMsg=ex.message;
                        ret=false;
                        return;
                    end
                end
                newRow{i}=val;%#ok<AGROW>
            end




            currentRow={...
            tabC.getValue([this.tabIdx,1]),...
            tabC.getValue([this.tabIdx,2]),...
            tabC.getValue([this.tabIdx,3]),...
            tabC.getValue([this.tabIdx,4])
            };
            if~isequal(currentRow,newRow)
                tabC.removeRow(this.tabIdx);
                if tabC.getNumberOfRows<this.tabIdx
                    tabC.addRow(newRow{1},newRow{2},newRow{3},newRow{4});
                else
                    tabC.insertRow(this.tabIdx,newRow{1},newRow{2},newRow{3},newRow{4});
                end

                soc.blkcb.RegisterChannelCb('SyncTableParams',this.blkH);
            end
        end
    end

    methods(Access=private)
        function validateTableParams(this,tabC,idx,val)
            blk='Register Channel';
            switch(idx)
            case 1
                param='Register name';

                if~this.isRegNameUnique(tabC,val)
                    error(message('soc:msgs:RegNameInUse',val));
                end
                if isempty(regexp(val,'^[A-Za-z]\w+$','ONCE'))
                    error(message('ERRORHANDLER:utils:InvalidInputParameter',blk,val,param));
                end
            case 3
                try
                    DataType=val;
                    DataType=evalin('base',DataType);
                catch ME %#ok<NASGU>

                end

                REG_MAX_WORDLEN=32;
                switch class(DataType)
                case 'Simulink.AliasType'
                    try
                        DataType=DataType.BaseType;
                        DataType=evalin('base',DataType);
                    catch ME %#ok<NASGU>

                    end
                    switch class(DataType)
                    case 'Simulink.NumericType'
                        if DataType.WordLength>REG_MAX_WORDLEN
                            error(message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
                        end

                    case 'char'

                        if any(strcmpi(DataType,{'double','int64','uint64'}))||isempty(regexp(DataType,'^[A-Za-z]\w+$','ONCE'))
                            error(message('soc:msgs:InvalidDataType',DataType));
                        end

                    otherwise
                        error(message('soc:msgs:InvalidDataType',DataType));
                    end

                case 'Simulink.NumericType'
                    if DataType.WordLength>REG_MAX_WORDLEN
                        error(message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
                    end

                case 'char'

                    if any(strcmpi(DataType,{'double','int64','uint64'}))||isempty(regexp(DataType,'^[A-Za-z]\w+$','ONCE'))
                        error(message('soc:msgs:InvalidDataType',DataType));
                    end

                otherwise
                    error(message('soc:msgs:InvalidDataType',DataType));

                end
            case 4
                param='Vector size';
                numVal=str2num(val);%#ok<ST2NM>
                if isscalar(numVal)&&mod(numVal,1)==0
                    validateattributes(numVal,{'numeric'},{'nonempty','positive','nonzero'},param);
                    return;
                elseif numel(numVal)==2
                    if numVal(1)==1||numVal(2)==1
                        return;
                    end
                end
                error(message('ERRORHANDLER:utils:InvalidInputParameter',blk,val,param));
            otherwise
                return;
            end
        end

        function isUnique=isRegNameUnique(this,tabC,name)
            isUnique=true;
            numRows=tabC.getNumberOfRows();
            for i=1:numRows
                regName=tabC.getTableCell([double(i),1]).Value;
                if isequal(regName,name)&&i~=this.tabIdx
                    isUnique=false;
                end
            end
        end

        function tabR=getTableParams(this)
            for i=1:this.NUMCOLS
                col=this.pMap(i);
                tabR.(col)=this.blkP.(col){this.tabIdx};
            end
        end

        function types=getSupportedTypes(~)
            types={...
            'single',...
            'int8',...
            'uint8',...
            'int16',...
            'uint16',...
            'int32',...
            'uint32',...
            'boolean',...
            'fixdt(1,16,0)',...
            'fixdt(1,16,2^0,0)',...
'<data type expression>'
            };
        end
    end
end