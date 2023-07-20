classdef(Hidden)TextFormatHelper<handle&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer





    properties(Constant)

        TEX_LABELSTRING="\color[rgb]{0.25 0.25 0.25}\rm";
        PINNED_VALUESTRING="\color[rgb]{0 0.6 1}\bf";
        TRANSIENT_VALUESTRING="\color[rgb]{0 0 0}\bf";
    end

    properties(Hidden)
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter='tex';
        UpdateFcn matlab.internal.datatype.matlab.graphics.datatype.Callback='';



        TexValueFormat=matlab.graphics.shape.internal.TextFormatHelper.PINNED_VALUESTRING;

        PixelsPerPoint;


        TextSize;
        TipDescriptors;
        isDataTipCustomizable=false;
    end

    methods
        function[textSize,textString,interpreter]=getTextStringFormatting(this,updateState,hFont,textString)
            interpreter=this.Interpreter;
            try
                textSize=updateState.getStringBounds(textString,hFont,this.Interpreter,'on');
            catch ex
                if strcmpi(ex.identifier,'MATLAB:hg:textutils:StringSyntaxError')



                    if isempty(this.UpdateFcn)
                        textString=erase(textString,[this.TEX_LABELSTRING,this.TexValueFormat]);
                    end
                    interpreter='none';

                    textSize=updateState.getStringBounds(textString,hFont,interpreter,'on');
                else
                    rethrow(ex);
                end
            end


            this.updateTipDescriptorsData(updateState,hFont,interpreter);
            this.TextSize=textSize;
            this.PixelsPerPoint=updateState.PixelsPerPoint;
        end

        function updateTipDescriptorsData(this,updateState,hFont,interpreter)
            try
                for i=1:numel(this.TipDescriptors)
                    if~isempty(this.TipDescriptors(i).Label)



                        this.TipDescriptors(i).LabelSize=updateState.getStringBounds(string(this.TipDescriptors(i).Label),...
                        hFont,interpreter,'on');
                    end
                    if~isempty(this.TipDescriptors(i).Value)



                        this.TipDescriptors(i).ValueSize=updateState.getStringBounds(string(this.TipDescriptors(i).Value),...
                        hFont,interpreter,'on');
                    end
                end
            catch
            end
        end

        function str=formatDatatipForStandardStringStrategy(this,hDescriptors,fontAngle,isPanelTip)

            descriptor_cells=cell(numel(hDescriptors),1);
            this.TipDescriptors=repmat(struct('Label','','Value','','LabelSize',0,'ValueSize',0),numel(hDescriptors),1);
            texLabelFormat='';
            texValueFormat='';





            if~isPanelTip&&strcmpi(this.Interpreter,'tex')
                texLabelFormat=this.TEX_LABELSTRING;
                texValueFormat=this.TexValueFormat;


                if strcmpi(fontAngle,'italic')
                    texLabelFormat=[texLabelFormat;'\it'];
                    texValueFormat=[texValueFormat;'\it'];
                end
            end
            for i=1:numel(hDescriptors)
                currStr=hDescriptors(i).Name;
                this.TipDescriptors(i).Label=currStr;
                if iscell(currStr)
                    descriptor_cells{i}=currStr(:);
                    this.TipDescriptors(i).Label=currStr(:);
                else
                    val=hDescriptors(i).Value;
                    this.TipDescriptors(i).Value=val;
                    if~isempty(val)


                        if isPanelTip
                            currStr=strcat(currStr,':');
                        end


                        spaceStr=' ';
                        if isempty(currStr)
                            spaceStr='';
                        end
                        if isnumeric(val)
                            if this.isDataTipCustomizable
                                currStr=sprintf('%s%s%s%s%s%s',...
                                texLabelFormat,currStr,spaceStr,texValueFormat,mat2str(val),texLabelFormat);
                            else
                                currStr=sprintf('%s%s%s%s%s%s',...
                                texLabelFormat,currStr,spaceStr,texValueFormat,mat2str(val,4),texLabelFormat);
                            end
                        elseif islogical(val)
                            currStr=sprintf('%s%s%s%s%s%s',...
                            texLabelFormat,currStr,spaceStr,texValueFormat,mat2str(double(val)),texLabelFormat);
                        elseif isdatetime(val)||isduration(val)
                            if numel(val)>1
                                currStr=sprintf('%s%s%s%s[%s]%s',...
                                texLabelFormat,currStr,spaceStr,texValueFormat,strtrim(sprintf('%s ',val)),texLabelFormat);
                            else
                                currStr=sprintf('%s%s%s%s%s%s',...
                                texLabelFormat,currStr,spaceStr,texValueFormat,val,texLabelFormat);
                            end
                        else
                            try
                                if~isPanelTip&&strcmpi(this.Interpreter,'tex')


                                    valueStr=sprintf('{%s}%s',char(val),texLabelFormat);
                                else
                                    valueStr=sprintf('%s',char(val));
                                end

                                currStr=[sprintf('%s%s%s%s',...
                                texLabelFormat,currStr,spaceStr,texValueFormat),valueStr];

                            catch


                            end
                        end
                    end
                    descriptor_cells{i}={currStr};
                end
            end
            str=cat(1,descriptor_cells{:});
        end
    end
end
