function wait_for_pending_uploads(context)
    fs = context.getFileService();
    while(fs.hasPendingUploads())
        fs.waitForPendingUploads(60, java.util.concurrent.TimeUnit.MINUTES);
    end
end