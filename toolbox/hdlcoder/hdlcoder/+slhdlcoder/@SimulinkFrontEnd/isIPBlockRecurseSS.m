function b=isIPBlockRecurseSS(impl)



    b=isa(impl,'hdlbuiltinimpl.HDLRecurseIntoSubsystem')||...
    isa(impl,'hdlimplbase.HDLRecurseIntoSubsystem');
end

