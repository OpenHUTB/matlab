function slrtCallbackTemplate(instrument, evnt, app)
%
% Get available data for signals.
% Signals are grouped together by common sample time and decimation.
% Data is available for one group of signals at a time (data is empty for
%   signals in other groups).
% Time vectors for all signals in a group are equal.
%
% This function must be on the MATLAB path.
%
% Example:
%     [time, data1] = instrument.getCallbackDataForSignal(evnt, 'Signal1');
%     [~,    data2] = instrument.getCallbackDataForSignal(evnt, 'Signal2');
%
%     if ~isempty(time)
%         if numel(time) == 1
%             % One time point of data is available
%             
%             [INSERT USER CODE HERE]
%             
%         else
%             % Multiple time points of data are available
%             sz = size(data);
%             if ndims(data) <= 2
%                 % 1D array - first dimension is time
%                 for i=1:sz(1) % handle each time point
%                     
%                     [INSERT USER CODE HERE]
%                     
%                 end
%             else
%                 % 2D array - last dimension is time
%                 for i=1:sz(end) % handle each time point
%                     
%                     [INSERT USER CODE HERE]
%                     
%                 end
%             end
%         end
%     end
    
    %<SLRT_TOKEN>

end
