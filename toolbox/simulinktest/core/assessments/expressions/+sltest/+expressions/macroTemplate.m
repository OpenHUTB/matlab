function templateHandle=macroTemplate(name,args,definition)
    import sltest.expressions.*
    templateHandle=TemplateHandle.makeMoveFrom(mi.macroTemplate(name,args,definition));
end
