function rtw_expand_template(inFileName, outFileName, isCPPEncap)
% RTW_EXPAND_TEMPLATE Expands a code generation template file to a executable
% TLC file (Embedded Coder feature).
%
% Arguments:
%   inFileName:  Name of a code generation template file to be expanded (.cgt)
%   outFileName: Name of the resulting TLC file (.tlc)
%
% For more details, see the Embedded Coder User's Guide for code generation
% template files.

%   Copyright 1994-2020 The MathWorks, Inc.
%
%   
%   

% Only expand .cgt files
[pathstr,file,ext] = fileparts(inFileName); 
if ~isequal(ext,'.cgt')
    DAStudio.error('RTW:targetSpecific:cgtFileNotFound',inFileName);
end

% Required tokens
requiredTokens = {...
    {'Includes'}, {'Defines'}, {'Types'}, {'Enums'},...
    {'Definitions'}, {'Declarations'}, {'Functions'}};

inId  = -1;
outId = -1;

try

  % Use auto-charset detection
  inId = fopen(inFileName,'r');
  if inId < 0
     DAStudio.error('RTW:utility:fileIOError',inFileName,'open');
 end
  
  % Load the file into a temporary buffer
  buffer = cell(2,1);
  lineCount = 0;
  rowCount = 0;
  while true
    str = fgetl(inId);
    if ~ischar(str), break, end % EOF
    lineCount = lineCount + 1;
    
    oldStyleIncStr = regexp(str,'^\s*%include\s+"rtwec_code.tlc"', 'once');
    if ~isempty(oldStyleIncStr)
      % Expand old style %include to tokens
      for i = 1 : length(requiredTokens)
        rowCount = rowCount + 1;
        buffer{rowCount}{1} = lineCount;
        buffer{rowCount}{2} = ['%<',requiredTokens{i}{1},'>'];
      end
    else
      rowCount = rowCount + 1;
      buffer{rowCount}{1} = lineCount;
      buffer{rowCount}{2} = str;
    end
  end


  % Variable to detect out of order or missing required tokens
  prevReqToken = '';

  % Need to store custom tokens in a list
  custTokenBuf = cell(1);
  custTokenIdx = 0;
  
  for rowCount = 1 : length(buffer)
    lineNo = buffer{rowCount}{1};
    istr = buffer{rowCount}{2};
    ostr = istr;
    
    % Skip TLC comments or lines without any tokens to expand
    if ~isempty(regexp(istr,'^\s*%%','ONCE')) || isempty(regexp(istr,'%<.*>','ONCE'))
      continue;
    end
    
    %Extract all tokens on this line (there may be more than one)
    %Example:
    %istr='/*First << %<!abc(e)>,second%<!uuuiii(dd,5+6)>>>,Invalid%<!err, Third%<rrt>ghgjjj%<*/'
    len = length(istr);
    
    %Get the indices of the beginning and augment the beginning 
    %with an end token out-of-range)
    idxb = [findstr(istr,'%<') len+1]; 
    
    tokens = {};
    for j = 1:length(idxb)-1
      for i = idxb(j): len    
        if strcmp(istr(i),'>')
          if (idxb(j) < i) && ( i < idxb(j+1))
            tokens{end+1} = istr(idxb(j):i); %#ok<AGROW>
            break
          end
        end
      end
    end

    nTokens = length(tokens);

    for i = 1 : nTokens
      token = tokens{i}(3:end-1);  %tokens{i}: %<!----> or %<---->
      if token(1) == '!'
        if isCPPEncap
            ostr = strrep(ostr,tokens{i},'');
        else
            % Escaped token (remove the escape '!' character)
            ostr = strrep(ostr,tokens{i},strrep(tokens{i},'!',''));
        end
      elseif rtwprivate('rtw_template_helper', 'isValid_buildinToken', 'FileBanner', token)
        % Recognized banner token (do nothing)
      elseif LocIsTokenInList(token,requiredTokens)
        % Recognized required token
        if nTokens > 1
            % Detected multiple tokens on a line containing a required token.
            % This is not permitted (to keep it simple and robust).
            DAStudio.error('RTW:targetSpecific:cgtMultipleTokens',...
                                inFileName,token,lineNo,istr);
        end

        ostr = strrep(ostr,tokens{i},[...
            '%<LibWriteFileSectionToDisk(fileIdx,"',token,'")>']);
        
        e = false;
        switch token
         case 'Includes'
          if ~isempty(prevReqToken), e = true; end
         case 'Defines'
          if ~strcmp(prevReqToken,'Includes'), e = true; end
         case 'Types'
          if ~strcmp(prevReqToken,'Defines'), e = true; end
         case 'Enums'
          if ~strcmp(prevReqToken,'Types'), e = true; end
         case 'Definitions'
          if ~strcmp(prevReqToken,'Enums'), e = true; end
         case 'Declarations'
          if ~strcmp(prevReqToken,'Definitions'), e = true; end
         case 'Functions'
          if ~strcmp(prevReqToken,'Declarations'), e = true; end
          otherwise
            DAStudio.error('RTW:targetSpecific:cgtUnknownToken',token);
        end
        
        if e
          LocOutOfOrderError(token,inFileName,istr,lineNo,requiredTokens);
        end
        
        prevReqToken = token;
      else
        if isCPPEncap
            ostr = strrep(ostr,tokens{i},'');
        else
            % Custom token
            ostr = strrep(ostr,tokens{i},[...
                '%<LibGetSourceFileCustomSection(fileIdx,"',token,'")>']);
            custTokenBuf{custTokenIdx+1} = token;
            custTokenIdx = custTokenIdx + 1;
        end
      end
    end
    
    % Write token expanded line.  Specific tokens are special handled.
    if strcmp(token,'Includes')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s',...
                  LocWriteFileGuard('#if'),...
                  LocWriteRTWToken('Includes'),...
                  LocWriteRTWToken('ModelTypesIncludes'));
    elseif strcmp(token, 'Defines')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s',...
                  LocWriteRTWToken('ModelTypesDefines'), ...
                  LocWriteRTWToken('GuardedIncludes'),...
                  LocWriteRTWToken('Defines'));
    elseif strcmp(token,'Types')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('ModelTypesTypedefs'), ...
                  LocWriteRTWToken('IntrinsicTypes'),...
                  LocWriteRTWToken('PrimitiveTypedefs'),...
                  LocWriteRTWToken('UserTop'),...
                  LocWriteRTWToken('Typedefs'));                  
    elseif strcmp(token,'Declarations')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('ExternData'),...
                  LocWriteRTWToken('ExternFcns'),...
                  LocWriteRTWToken('FcnPrototypes'),...
                  LocWriteRTWToken('Declarations'));
    elseif strcmp(token,'Functions')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('Functions'),...
                  LocWriteRTWToken('CompilerErrors'),...
                  LocWriteRTWToken('CompilerWarnings'),...
                  LocWriteRTWToken('Documentation'),...
                  LocWriteRTWToken('UserBottom'),...
                  LocWriteFileGuard('#endif'));
    else
      buffer{rowCount}{2} = ostr;
    end
    
  end
  
  % Ensure that 'Functions' was the last required token
  if ~strcmp(prevReqToken,'Functions')
     DAStudio.error('RTW:targetSpecific:cgtTokenMissing',inFileName);
  end
  
  % Use UTF-8 to preserve data integrity
  outId = fopen(outFileName,'w','n','UTF-8');
  if outId < 0
      DAStudio.error('RTW:utility:fileIOError',outFileName,'open');
  end
  
  % Write a timestamp on the top of the file.
  timestampstr = sprintf([...
      '%%%%\n',...
      '%%%% Auto generated by Simulink Coder on %s from file:\n',...
      '%%%% %s\n',...
      '%%%%\n'],datestr(now),which(inFileName));
  fprintf(outId,'%s',timestampstr);

  % Write all the custom tokens that were found
  if ~isempty(custTokenBuf{1})
    fprintf(outId,'%%%% Identified custom tokens in code generation template:\n');
    fprintf(outId,'%%%%\n');
    custTokenBuf = sort(custTokenBuf);
    fprintf(outId,'%s\n',LocTokenFoundStr(custTokenBuf{1}));
    for idx = 2 : length(custTokenBuf)
      if ~isequal(custTokenBuf{idx},custTokenBuf{idx-1})
        fprintf(outId,'%s\n',LocTokenFoundStr(custTokenBuf{idx}));
      end
    end
    fprintf(outId,'%%%%\n');
  end
      
  % Write all the contents of the expanded file
  for rowCount = 1 : length(buffer)
    fprintf(outId,'%s\n',buffer{rowCount}{2});
  end

  % Write EOF comment
  fprintf(outId,'%%%% [EOF]\n');
  LocCloseFiles(inId,outId);

catch exc

  % Clean up files and throw last error
  LocCloseFiles(inId,outId);
  rethrow(exc);
  
end


% Close files
function LocCloseFiles(fid1,fid2)
  if fid1 ~= -1
    fclose(fid1);
  end
  if fid2 ~= -1
    fclose(fid2);
  end
  

% Find a token in a list of tokens
function value = LocIsTokenInList(token,tokenList)
  for i = 1 : length(tokenList)
    if strcmp(token,tokenList{i})
      value = true;
      return;
    end
  end
  value = false;
  
  
% Write a required token with its appropriate expansion
function str = LocWriteRTWToken(token)
  str = sprintf('%%<LibWriteFileSectionToDisk(fileIdx,"%s")>',token);    

% Write that a custom token was found
function str = LocTokenFoundStr(token)
  str = ['%<SLibSetSourceFileCustomTokenInUse(fileIdx,"',token,'")>'];
  
% Write the header file guard 
%   mode: #if    (top)
%         #endif (bottom)
function str = LocWriteFileGuard(mode)
  if strcmp(mode,'#if')
      str = sprintf([...
          '%%assign needGuard = LibGetModelFileNeedHeaderGuard(fileIdx)\n',...
          '%%if needGuard\n\n',...
          '  #ifndef RTW_HEADER_%%<FileTag>_\n',...
          '  #define RTW_HEADER_%%<FileTag>_\n',...
          '%%endif']);
  elseif strcmp(mode,'#endif')
      str = sprintf([...
          '%%if needGuard\n\n',...
          '  #endif /* RTW_HEADER_%%<FileTag>_ */\n',...
          '%%endif']);
  else
      DAStudio.error('RTW:targetSpecific:cgtUnknownHeaderfileMode',mode);
  end


% Report an error for out of order or missing tokens.
function LocOutOfOrderError(token,fname,str,count,reqtokens)
    txt = '';
    for i = 1 : length(reqtokens)
        txt = sprintf('%s  %s\n',txt,reqtokens{i}{1});
    end
    DAStudio.error('RTW:targetSpecific:cgtOutOfOrderToken',...
                   token,fname,txt,count,fname,str);

% LocalWords:  cgt latin loseless rtwec istr abc uuuiii rrt ghgjjj buildin SLCG
% LocalWords:  SLib Headerfile
