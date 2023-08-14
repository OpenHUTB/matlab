function this=HDLEntitySignalTable(varargin)


    persistent hdlEntitySignalTableInstance;

    if~isempty(varargin)&&strcmpi(varargin{1},'table')
        if isempty(varargin{2})
            error(message('HDLShared:hdlshared:constructorerror'));
        end
        New=varargin{2};
    else
        New='';
    end

    if isempty(New)
        if isempty(hdlEntitySignalTableInstance)||...
            ~isa(hdlEntitySignalTableInstance,'hdlshared.HDLEntitySignalTable')
            hdlEntitySignalTableInstance=hdlshared.HDLEntitySignalTable;
        end
    elseif isa(New,'hdlshared.HDLEntitySignalTable')
        hdlEntitySignalTableInstance=New;
    elseif strcmpi(New,'New')
        hdlEntitySignalTableInstance=hdlshared.HDLEntitySignalTable;
    else
        error(message('HDLShared:hdlshared:signalTableerror'));
    end


    this=hdlEntitySignalTableInstance;


