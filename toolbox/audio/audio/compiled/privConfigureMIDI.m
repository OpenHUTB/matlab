function varargout=privConfigureMIDI(varargin)





    narginchk(1,5);

    [varargin{:}]=convertStringsToChars(varargin{:});

    arg1=varargin{1};

    if ischar(arg1)&&strcmp(arg1,'disconnect')



        narginchk(1,2);
        ObjectUnderTest=parse_disconnect_args(varargin{2:end});
        disconnect(ObjectUnderTest.getMIDIInterface);
    elseif ischar(arg1)&&strcmp(arg1,'getConnections')



        narginchk(2,2);
        ObjectUnderTest=varargin{2};
        MIDIInterface.checkObjectValidity(ObjectUnderTest);
        varargout{1}=getConnections(ObjectUnderTest.getMIDIInterface);
    else







        [ObjectUnderTest,Property,ControlNumber,DeviceName,EnableCodeGeneration]=parse_config_args(varargin{:});
        if isa(ObjectUnderTest,'audioPlugin')
            checkPluginClass(class(ObjectUnderTest));
        end
        configure(ObjectUnderTest.getMIDIInterface,Property,ControlNumber,DeviceName,EnableCodeGeneration);
    end

end

function[OBJ,Property,ControlNumber,DeviceName,EnableCodeGeneration]=parse_config_args(varargin)
    parser=inputParser;
    parser.KeepUnmatched=true;
    addRequired(parser,'OBJ',@MIDIInterface.checkObjectValidity);
    addOptional(parser,'Property','',@(x)(isnumeric(x)||ischar(x)));
    addOptional(parser,'ControlNumber',[],@isnumeric);
    addParameter(parser,'DeviceName','');
    addParameter(parser,'EnableCodeGeneration',true);
    parse(parser,varargin{:});
    OBJ=parser.Results.OBJ;
    coder.internal.errorIf((isa(OBJ,'audioPlugin')&&~isa(OBJ,'audio.internal.loadableAudioPlugin'))...
    &&~isprop(OBJ,'PluginInterface'),'audio:shared:MIDINoPluginInterface');
    Property=parser.Results.Property;
    if~isempty(Property)

        if isa(OBJ,'audio.internal.loadableAudioPlugin')

            getParameter(OBJ,Property);
        else
            validateattributes(Property,{'char'},{'vector'});
            if isa(OBJ,'audioPlugin')
                params=OBJ.PluginInterface.Parameters;
                coder.internal.errorIf(~isfield(params,Property),'audio:shared:MIDINotPluginParameter',Property);
            else
                params=OBJ.getDefaultPluginInterface.Parameters;
                flag=false;
                props=properties(OBJ);
                if~isfield(params,Property)
                    flag=true;
                    if any(contains(props,Property))&&isfield(params,[Property,'1'])...
                        &&isfield(params,[Property,num2str(length(OBJ.(Property)))])
                        flag=false;
                    end
                end
                coder.internal.errorIf(flag,'audio:shared:MIDINotPublicTunableProp',Property);
            end
        end
    end
    ControlNumber=parser.Results.ControlNumber;
    DeviceName=parser.Results.DeviceName;
    EnableCodeGeneration=parser.Results.EnableCodeGeneration;
end

function OBJ=parse_disconnect_args(varargin)
    parser=inputParser;
    addOptional(parser,'OBJ','',@MIDIInterface.checkObjectValidity);
    parse(parser,varargin{:});
    OBJ=parser.Results.OBJ;
end
