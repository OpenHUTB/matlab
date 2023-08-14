function logMessage(input,channel)




    transferTypes={'send','receive','peek','pop','drop'};

    if isstruct(input)

        if strcmp(input.type,'init')

            SequenceDiagramViewer.handleInit(input.actors);
            SequenceDiagramViewer.handleLifelines(input.actors);

        else

            thisTransferType=transferTypes{input.type+1};
            input.type=thisTransferType;

            if strcmp(thisTransferType,'send')
                SequenceDiagramViewer.handleMessageStart(input);
            else
                SequenceDiagramViewer.handleMessageEnd(input);
            end
        end

    elseif ischar(input)&&nargin==2&&ischar(channel)

        message.publish(channel,input);

    end
end
