// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   UpdateMetadata.java

package com.mathworks.addons_common;

import com.mathworks.addons_common.util.ImageUtils;
import com.mathworks.addons_common.util.MetadataFileUtils;
import java.awt.image.BufferedImage;

// Referenced classes of package com.mathworks.addons_common:
//            UpdateType

public final class UpdateMetadata
{
    public static class Builder
    {

        public Builder downloadUrl(String s)
        {
            downloadUrl = s;
            return this;
        }

        public Builder whatsNew(String s)
        {
            whatsNew = s;
            return this;
        }

        public Builder authorName(String s)
        {
            authorName = s;
            return this;
        }

        public Builder releaseNotesUrl(String s)
        {
            releaseNotesUrl = s;
            return this;
        }

        public Builder licenseAgreementUrl(String s)
        {
            licenseAgreementUrl = s;
            return this;
        }

        public Builder updateLevel(String s)
        {
            updateLevel = s;
            return this;
        }

        public Builder matlabUpdateLinkUrl(String s)
        {
            matlabUpdateLinkUrl = s;
            return this;
        }

        public Builder matlabUpdateLinkLabel(String s)
        {
            matlabUpdateLinkLabel = s;
            return this;
        }

        public UpdateMetadata createUpdateMetadata()
        {
            return new UpdateMetadata(this);
        }

        private String identifier;
        private String version;
        private String name;
        private String addOnType;
        private String imageData;
        private String authorName;
        private String whatsNew;
        private String downloadUrl;
        private String updateType;
        private String releaseNotesUrl;
        private String licenseAgreementUrl;
        private String updateLevel;
        private String matlabUpdateLinkLabel;
        private String matlabUpdateLinkUrl;















        Builder(String s, String s1, String s2, String s3, String s4, String s5)
        {
            matlabUpdateLinkLabel = "";
            matlabUpdateLinkUrl = "";
            identifier = s;
            version = s1;
            name = s2;
            addOnType = s3;
            imageData = s4;
            updateType = s5;
        }
    }


    public static Builder getBuilder(String s, String s1, String s2, String s3, BufferedImage bufferedimage, UpdateType updatetype)
    {
        return new Builder(s, s1, s2, s3, ImageUtils.convertImageToDataUri(bufferedimage), updatetype.toString());
    }

    private UpdateMetadata(Builder builder)
    {
        matlabUpdateLinkLabel = "";
        matlabUpdateLinkUrl = "";
        identifier = builder.identifier;
        version = builder.version;
        name = builder.name;
        addOnType = builder.addOnType;
        imageData = builder.imageData;
        updateType = builder.updateType;
        if(builder.authorName != null)
            authorName = builder.authorName;
        if(builder.whatsNew != null)
            whatsNew = builder.whatsNew;
        if(builder.downloadUrl != null)
            downloadUrl = builder.downloadUrl;
        if(builder.addOnType.equalsIgnoreCase("zip"))
            downloadUrl = MetadataFileUtils.getMetadataUrlAsStringForAddOn(builder.identifier, builder.version);
        if(builder.releaseNotesUrl != null)
            releaseNotesUrl = builder.releaseNotesUrl;
        if(builder.licenseAgreementUrl != null)
            licenseAgreementUrl = builder.licenseAgreementUrl;
        if(builder.updateLevel != null)
            updateLevel = builder.updateLevel;
        if(builder.matlabUpdateLinkLabel != null)
            matlabUpdateLinkLabel = builder.matlabUpdateLinkLabel;
        if(builder.matlabUpdateLinkUrl != null)
            matlabUpdateLinkUrl = builder.matlabUpdateLinkUrl;
    }

    public String getVersion()
    {
        return version;
    }

    public String getIdentifier()
    {
        return identifier;
    }

    public String getUpdateType()
    {
        return updateType;
    }

    public String getName()
    {
        return name;
    }

    public String getUpdateLevel()
    {
        return updateLevel;
    }

    public String getMatlabUpdateLinkUrl()
    {
        return matlabUpdateLinkUrl;
    }

    public String getMatlabUpdateLinkLabel()
    {
        return matlabUpdateLinkLabel;
    }


    private String identifier;
    private String version;
    private String name;
    private String addOnType;
    private String imageData;
    private String authorName;
    private String whatsNew;
    private String downloadUrl;
    private String updateType;
    private String releaseNotesUrl;
    private String licenseAgreementUrl;
    private String matlabUpdateLinkLabel;
    private String matlabUpdateLinkUrl;
    private String updateLevel;
}
