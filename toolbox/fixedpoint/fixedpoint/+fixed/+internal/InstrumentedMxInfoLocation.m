classdef InstrumentedMxInfoLocation<handle




    properties(Access=public)
NodeTypeName
MxInfoID
TextStart
TextLength
    end
    properties(Access=public)
MxInfoIDStr
IsLoggedLocation
IsInstrumented
        IsArgin=false
        IsArgout=false
        IsGlobal=false
        IsPersistent=false
SimMin
SimMax
OverflowWraps
Saturations
IsAlwaysInteger
NumberOfZeros
NumberOfPositiveValues
NumberOfNegativeValues
TotalNumberOfValues
SimSum
HistogramOfPositiveValues
HistogramOfNegativeValues
LoggedFieldNames
LoggedFieldMxInfoIDs
LoggedFieldToolTipIDs
ProposedSignedness
ProposedWordLengths
ProposedFractionLengths
OutOfRange
RatioOfRange
LogID
ToolTipID
SymbolID
SymbolName
Reason









VarIDsArrayIndex
    end

    methods(Access=public)
        function self=InstrumentedMxInfoLocation(MxInfoLocation,NumberOfHistogramBins,MxInfos)

            if nargin==0

                return
            end
            if~isa(MxInfoLocation,'eml.InferMxInfoLocation')
                error(message('fixed:instrumentation:InputNotEmlInferMxInfoLocation'));
            end
            [isArgin,isArgout,isGlobal,isPersistent]=...
            fixed.internal.InstrumentedMxInfoLocation.get_scope_from_MxInfoLocation(MxInfoLocation);




            mx_info_id=MxInfoLocation.MxInfoID;
            if(isa(MxInfos{mx_info_id},'eml.MxStructInfo')...
                ||isa(MxInfos{mx_info_id},'eml.MxClassInfo'))...
                &&fixed.internal.InstrumentedMxInfoLocation.is_loggable(MxInfos{mx_info_id},MxInfos)

                [loggable_field_name_cell,loggable_field_mx_info_ids]=...
                fixed.internal.InstrumentedMxInfoLocation.get_loggable_fields_from_struct(mx_info_id,MxInfos);

                number_of_fields=length(loggable_field_mx_info_ids);
                if number_of_fields==0
                    number_of_fields=1;
                end
                siz=[1,number_of_fields];
            elseif isa(MxInfos{mx_info_id},'eml.MxCellInfo')...
                &&fixed.internal.InstrumentedMxInfoLocation.is_loggable(MxInfos{mx_info_id},MxInfos)

                loggable_field_name_cell={};
                loggable_field_mx_info_ids={};
                number_of_fields=1;
                siz=[1,1];
            else
                loggable_field_name_cell={};
                loggable_field_mx_info_ids={};
                number_of_fields=1;
                siz=[1,1];
            end



            self.NodeTypeName=MxInfoLocation.NodeTypeName;
            self.MxInfoID=mx_info_id;


            self.TextStart=MxInfoLocation.TextStart+1;
            self.TextLength=MxInfoLocation.TextLength;
            self.MxInfoIDStr=int2str(self.MxInfoID);
            self.IsLoggedLocation=false;
            self.IsInstrumented=false;
            self.IsArgin=isArgin;
            self.IsArgout=isArgout;
            self.IsGlobal=isGlobal;
            self.IsPersistent=isPersistent;
            self.SimMin=inf(siz);
            self.SimMax=-inf(siz);
            self.OverflowWraps=zeros(siz);
            self.Saturations=zeros(siz);
            self.IsAlwaysInteger=true(siz);
            self.NumberOfZeros=zeros(siz);
            self.NumberOfPositiveValues=zeros(siz);
            self.NumberOfNegativeValues=zeros(siz);
            self.TotalNumberOfValues=zeros(siz);
            self.SimSum=zeros(siz);
            self.HistogramOfPositiveValues=zeros(number_of_fields,NumberOfHistogramBins);
            self.HistogramOfNegativeValues=zeros(number_of_fields,NumberOfHistogramBins);
            self.LoggedFieldNames=loggable_field_name_cell;
            self.LoggedFieldMxInfoIDs=loggable_field_mx_info_ids;
            self.LoggedFieldToolTipIDs={};
            self.ProposedSignedness={};
            self.ProposedWordLengths={};
            self.ProposedFractionLengths={};
            self.OutOfRange={};
            self.RatioOfRange={};
            self.LogID=0;
            self.ToolTipID=0;
            self.SymbolID=0;
            self.SymbolName='';
            self.Reason=0;
            self.VarIDsArrayIndex=[];
        end
    end

    methods(Static,Access=private)
        function[loggable_field_name_cell,loggable_field_mx_info_ids]=...
            get_loggable_fields_from_struct(mx_info_id,MxInfos)







            [~,~,field_names_cell,field_mx_infos]=...
            fixed.internal.InstrumentedMxInfoLocation.get_field_names_from_struct(mx_info_id,MxInfos);
            loggable_field_name_cell=field_names_cell;
            loggable_field_mx_info_ids=field_mx_infos;
            for i=length(field_mx_infos):-1:1
                this_mx_info=MxInfos{field_mx_infos{i}(end)};
                if(~isa(this_mx_info,'eml.MxFiInfo')&&...
                    ~isa(this_mx_info,'eml.MxNumericInfo')&&...
                    ~(isa(this_mx_info,'eml.MxInfo')&&...
                    isequal(this_mx_info.Class,'logical')))||...
                    prod(this_mx_info.Size)==0

                    loggable_field_mx_info_ids(i)=[];
                    loggable_field_name_cell(i)=[];
                end
            end
        end

        function[this_field_name_cell,this_field_mx_info_ids,field_names_cell,field_mx_info_ids]=...
            get_field_names_from_struct(mx_info_id,...
            MxInfos,...
            this_field_name_cell,this_field_mx_info_ids,...
            field_names_cell,field_mx_info_ids)




            if nargin<3
                this_field_name_cell={};
            end
            if nargin<4
                this_field_mx_info_ids=[];
            end
            if nargin<5
                field_names_cell={};
            end
            if nargin<6
                field_mx_info_ids={};
            end
            mx_info=MxInfos{mx_info_id};
            switch class(mx_info)
            case 'eml.MxClassInfo'


                for i=1:length(mx_info.ClassProperties)


                    this_field_name_cell{end+1}=mx_info.ClassProperties(i).PropertyName;%#ok<*AGROW>
                    this_field_mx_info_ids(end+1)=mx_info.ClassProperties(i).MxInfoID;
                    [this_field_name_cell,this_field_mx_info_ids,...
                    field_names_cell,field_mx_info_ids]=...
                    fixed.internal.InstrumentedMxInfoLocation.get_field_names_from_struct(...
                    mx_info.ClassProperties(i).MxInfoID,...
                    MxInfos,this_field_name_cell,this_field_mx_info_ids,...
                    field_names_cell,field_mx_info_ids);
                end

                this_field_name_cell=this_field_name_cell(1:end-1);
                this_field_mx_info_ids=this_field_mx_info_ids(1:end-1);
            case 'eml.MxStructInfo'


                for i=1:length(mx_info.StructFields)


                    this_field_name_cell{end+1}=mx_info.StructFields(i).FieldName;%#ok<*AGROW>
                    this_field_mx_info_ids(end+1)=mx_info.StructFields(i).MxInfoID;
                    [this_field_name_cell,this_field_mx_info_ids,...
                    field_names_cell,field_mx_info_ids]=...
                    fixed.internal.InstrumentedMxInfoLocation.get_field_names_from_struct(...
                    mx_info.StructFields(i).MxInfoID,...
                    MxInfos,this_field_name_cell,this_field_mx_info_ids,...
                    field_names_cell,field_mx_info_ids);
                end

                this_field_name_cell=this_field_name_cell(1:end-1);
                this_field_mx_info_ids=this_field_mx_info_ids(1:end-1);
            otherwise



                field_name=sprintf('%s.',this_field_name_cell{:});
                field_name(end)='';
                field_names_cell{end+1}=field_name;

                field_mx_info_ids{end+1}=this_field_mx_info_ids;

                this_field_name_cell=this_field_name_cell(1:end-1);
                this_field_mx_info_ids=this_field_mx_info_ids(1:end-1);
            end
        end

        function t=is_loggable(mx_info,MxInfos)




            t=false;
            switch class(mx_info)
            case{'eml.MxFiInfo','eml.MxNumericInfo'}
                t=true;
            case 'eml.MxStructInfo'


                for i=1:length(mx_info.StructFields)
                    t=fixed.internal.InstrumentedMxInfoLocation.is_loggable(MxInfos{mx_info.StructFields(i).MxInfoID},MxInfos);
                    if t==true
                        break
                    end
                end
            case 'eml.MxClassInfo'


                for i=1:length(mx_info.ClassProperties)
                    t=fixed.internal.InstrumentedMxInfoLocation.is_loggable(MxInfos{mx_info.ClassProperties(i).MxInfoID},MxInfos);
                    if t==true
                        break
                    end
                end
            case 'eml.MxCellInfo'


                for i=1:length(mx_info.CellElements)
                    t=fixed.internal.InstrumentedMxInfoLocation.is_loggable(MxInfos{mx_info.CellElements(i)},MxInfos);
                    if t==true
                        break
                    end
                end
            case{'eml.MxInfo'}
                if isequal(mx_info.Class,'logical')
                    t=true;
                end
            end
        end

        function[isArgin,isArgout,isGlobal,isPersistent]=get_scope_from_MxInfoLocation(MxInfoLocation)
            isArgin=false;
            isArgout=false;
            isGlobal=false;
            isPersistent=false;
            switch MxInfoLocation.NodeTypeName
            case 'inputVar'
                isArgin=true;
            case 'outputVar'
                isArgout=true;
            case 'globalVar'
                isGlobal=true;
            case 'persistentVar'
                isPersistent=true;
            end
        end

    end

end
