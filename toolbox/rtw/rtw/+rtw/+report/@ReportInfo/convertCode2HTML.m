function convertCode2HTML( obj )



oldDir = cd( obj.getReportDir );
coder.internal.slcoderReport( 'convertC2HTML', obj.getContentsFileFullName, obj.ModelName, ~strcmp( obj.ModelReferenceTargetType, 'NONE' ), obj.BuildDirectory, obj );
if rtw.report.ReportInfo.DisplayInCodeTrace && ~obj.hasWebview
loc_c2html( obj, strcmp( obj.Config.IncludeHyperlinkInReport, 'on' ), obj.Encoding );
end 
cd( oldDir );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppqOh0r.p.
% Please follow local copyright laws when handling this file.

