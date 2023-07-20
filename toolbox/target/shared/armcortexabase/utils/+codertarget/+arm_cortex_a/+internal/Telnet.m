%

%   Copyright 2014-2018 The MathWorks, Inc.

classdef Telnet < handle
    %TELNET A thin wrapper class to talk telnet
    %   Detailed explanation goes here
    
    properties (Constant)
        READBUFFERSIZE            = 64*1024;
        INPUTBUFFERSIZE           = 64*1024;
        OUTPUTBUFFERSIZE          = 2048;
        TIMEOUT                   = 40;
    end
    properties
        Socket
        Hostname
        Port        
    end
        
    properties (Hidden, SetAccess=private)
        ShellPrompt = '';
    end
    
    methods
        function this = Telnet(hostname, port, shPrompt)
            narginchk(2, 3);
            if nargin < 3
                shPrompt = '->';
            end
            this.Hostname = hostname;
            this.Port = port;
            this.ShellPrompt = shPrompt;
        end
        
        function open(this, varargin)
            this.Socket = matlabshared.network.internal.TCPClient(this.Hostname, this.Port);
            this.Socket.InputBufferSize  = this.INPUTBUFFERSIZE;
            this.Socket.OutputBufferSize = this.OUTPUTBUFFERSIZE;
            this.Socket.ConnectTimeout = this.TIMEOUT;
            connect(this.Socket);
        end
        
        function cmd(this, cmdStr)
            cmdStr = [cmdStr, 13];
            write(this.Socket, uint8(cmdStr(:)));
        end
        
        function output = waitForResponse(this, response, timeout)
            tstart = tic;
            tstop = toc(tstart);
            output = '';
            while (tstop < timeout)
                tmp = read(this.Socket, this.Socket.NumBytesAvailable);
                tmp = reshape(tmp, 1, length(tmp));
                output = strcat(output, char(tmp));  % Concatenate 
                if isempty(response)
                    % User wants to clear out the receive buffer
                    return;
                end
                m = regexpi(output, response, 'match', 'once');
                if ~isempty(m)
                    break;
                end
                tstop = toc(tstart);
            end
            if (tstop > timeout)
                flushInput(this.Socket);
                error('a:b', 'Timed out waiting for response from target');
            end
        end
        
        function close(this)
            disconnect(this.Socket);
        end
        function delete(this)
            this.Socket = [];
        end
        
    end
    
end

