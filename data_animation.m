%% Movie + data display
% Lili Cai

% (1) Input files: 
%     (a) Your raw video 
%         --> extract and save individual frames from movie into .jpg images
%         --> note the sampling rate
%     (b) Your neural data 
%         --> down or up-sample to match raw video sampling rate
%     (c) Your behavioral data
%         --> down or up-sample to match raw video sampling rate
%         --> format your data for plotting
% (2) Plot each "frame" of the movie along with each "frame" of your data
%     and what you want it to look like
%     (a) Set axis locations for the text in the figure you want to create
%     (b) For each figure/frame (which now shows your movie and data), save as a
%     .jpg
% (3) Compile the saved frames into a video

% The example below has: 
% (a) A movie of an animal freezing to a tone
% (b) GCamp trace during the animal behavior
% (c) Freezing during the animal behavior

%% Part (1) Load Input files
% (1a) Input movie. Movie is in 11.23 Hz
vid = VideoReader('video.avi');
    % starts at 192 s, then goes on to 558 frames. need only 561. 

    % Extract individual frames from the movie into jpg files
    l_trace = floor(vid.FrameRate*vid.Duration);   % number of frames in movie, this parameter is something you need to set
                     % you can know the number of frames in the movie by
                     % just typing "vid" in the command line, 
                     % it is Duration*FrameRate
    ii = 1; 

    while hasFrame(vid)
        img = readFrame(vid);
        img = img(60:210,100:235,:);  % crop image
        filename = ['image' sprintf('%03d',ii) '.jpg']; 
        fullname = fullfile(filename);
        imwrite(img, fullname) %Write out to a JPEG file
        ii = ii+1; 
    end
    
    % Get a variable that contains all the file names of the .jpgs you just
    % created, so you can call on them later
    imageNames = dir(fullfile('image*.jpg'));  % This are the jpg files you just created
    imageNames = {imageNames.name}';

% (1b) Load GCaMP data
% Here, the GCaMP data is 100 Hz. We will sample every 9, to bring it down
% to 11.23 Hz. 
gcamp_fs = 100; 
gcamp_to_video_factor = round(gcamp_fs / vid.FrameRate); 
gcamp = load('data_neural.mat');
gcamp = gcamp.temp_gcamp; 
temp2 = gcamp(1:gcamp_to_video_factor:end); % resample gcamp data so it matches video rate
temp2 = temp2(1:l_trace);  % cut off later data

% (1c) Load scored freezing data - freezing is in 1 Hz. We need to match this to
% 11.23 Hz of the video
temp = xlsread('data_behavioral.xlsx')';
%temp = temp(1:l_trace/n);  % cut off extra data
frz = repmat(temp',1,round(vid.FrameRate))';
frz = frz(:)'; % format freezing data in a matrix so when you plot it, it looks animated
frz = frz(1:l_trace);
A = frz;  % cut off extra data at end
    c_bar = 1:100; 


%% Part (2) Generate each frame of movie you want to make

% (2a) Define axis locations for the figure you want to create
x_start = .19;
h = figure(1), clf, hold on, set(gcf, 'color', 'white'), axis off
    % create individual subplots of where you want things in your figure
    subplot('position', [.1 .22 .8 .1]); hold on; axis off;
    xlim([1 l_trace]), ylim([0 10])
    
    annotation(figure(1),'textbox',...
    [0.8 0.8 0.18 0.025],...
    'String','% Freezing',...
    'LineStyle','none',...
    'FontSize',10,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    annotation(figure(1),'textbox',...
    [0.03 0.22 0.13 0.04],...
    'String','GCamp6f',...
    'LineStyle','none',...
    'FontSize',10,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    annotation(figure(1),'textbox',...
    [0.006 0.18 0.17 0.026],...
    'String','% Freezing',...
    'LineStyle','none',...
    'FontSize',10,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

    subplot('position', [x_start .15 .1 .02])
    imagesc(c_bar), colormap(hot); caxis([0 200])
    set(gca, 'ytick', [])
    set(gca, 'xtick', [1 100])
    set(gca, 'xticklabel', {'0'; '50'; '100'}, 'fontsize', 20)
    

% (2b) Generate each frame    
for j = 1:l_trace 
    img = imread(imageNames{j});
    
    % plot video
    subplot('position',[x_start .4 .82 .6]), axis off; hold on; 
    imagesc(img)
    
    % plot gcamp trace ---- check where ylim is and where gcamp trace is
    subplot('position', [x_start .22 .8 .1]); hold on; 
    xlim([1 l_trace]); ylim([min(temp2) max(temp2)])
    plot(1:j,temp2(1:j),'color', 'k', 'linewidth',3); axis off; hold on; 
        
    % plot %Freezing during cue
    ha = axes('position',[.9 .85 .07 .07]); hold on; 
    imagesc(A(j)); colormap(hot); caxis([0 200])
    axis off
    %pause(.00001)
    
    % plot imagesc of freeze
    subplot('position', [x_start .18 .8*(j/l_trace) .02]); 
    imagesc(frz(1:j)), colormap(hot), caxis([0 200]), axis off
    
    % drawnow
    set(h, 'PaperPositionMode','auto')
    saveas(h, ['vid_' num2str(j) '.jpg']);

end

%% (3) Compile images into video
outputVideo = VideoWriter('data_animated.avi')
outputVideo.FrameRate = 20;  % How fast do you want the video to play? Change this parameter
open(outputVideo); 

for ii = 1:l_trace
    img = imread(['vid_' num2str(ii) '.jpg']);
    writeVideo(outputVideo, img); 
end

close(outputVideo)

