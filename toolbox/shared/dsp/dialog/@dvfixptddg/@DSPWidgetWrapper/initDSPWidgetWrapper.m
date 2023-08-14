function this=initDSPWidgetWrapper(this,dlgSchema,blockInfo,userData)








    this.DialogSchema=dlgSchema;
    this.DialogSchema.Source=this;

    if nargin>2
        if(length(blockInfo.propNames)~=length(blockInfo.propTypes))
            error(message('dspshared:dialog:invalidInput'));
        end
        this.PropNames=blockInfo.propNames;
        this.PropTypes=blockInfo.propTypes;
        this.Block=blockInfo.block;
        for ind=1:length(this.propNames)
            schema.prop(this,this.propNames{ind},this.propTypes{ind});
        end
    end

    this.UserData=userData;
