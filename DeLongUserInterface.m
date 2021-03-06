function DeLongUserInterface()
%%
%% Reference:
% @article{sun2014fast,
%   title={Fast Implementation of DeLong's Algorithm for Comparing the Areas Under Correlated Receiver Operating Characteristic Curves},
%   author={Xu Sun and Weichao Xu},
%   journal={IEEE Signal Processing Letters},
%   volume={21},
%   number={11},
%   pages={1389--1393},
%   year={2014},
%   publisher={IEEE}
% }
%% Edited by X. Sun.
%  Version: 2014/12

close all;
clear all;

%% Initialize figure

hight = 500;
width = 550;

mainf = figure;
set(mainf, 'Name', 'ROC Analysis', 'NumberTitle', 'off');
posf = get(mainf, 'Position');
posf = [posf(1) + posf(3) /  2 - width / 2, ...
    posf(2) + posf(4) - hight, width, hight];
set(mainf, 'Position', posf);
set(gcf,'color','w');

%% External function

% Get filename list
getFileList_ = @getFileList;
% Load samples
loadsamples_ = @loadsamples;
% Plot ROC curves
plotroc_ = @plotroc_discrete;
% Calculate aucs and covariance matrix
calroc_ = @fastDeLong;
% Calculate p-value
calpvalue_ = @calpvalue;

%% Initialize variables

fileList = getFileList_();
samples = [];
aucs = [];
delongcov = [];
rating1i = 1;
rating2i = 1;
filename = fileList{1};

%% Initialize uicontrol

% Titletext
uicontrol('style','text',...
           'String', 'ROC Analysis',...
           'Position', [190, 450, 175, 40],...
           'Fontsize', 20,...
           'Backgroundcolor', 'w');

% Selectef File text
uicontrol('style','text',...
           'String', 'Selectef File :',...
           'Position', [32, 410, 90, 19],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');
       
% Selected File popup
uisfp = uicontrol('style','popup',...
           'String', fileList,...
           'Position', [127, 414, 90, 19],...
           'Fontsize', 8,...
           'Backgroundcolor', 'w',...
           'Callback', @clearAxes);
       
% Rating 1 text
uicontrol('style','text',...
           'String', 'Rating 1 :',...
           'Position', [227, 410, 90, 19],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');
       
% Rating 1 popup
uir1p = uicontrol('style','popup',...
           'String', 'No Ratings',...
           'Position', [311, 414, 90, 19],...
           'Fontsize', 8,...
           'Backgroundcolor', 'w',...
           'ForegroundColor', 'b',...
           'Callback', @setrating1);
       
% Rating 2 text
uicontrol('style','text',...
           'String', 'Rating 2 :',...
           'Position', [227, 376, 90, 19],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');
       
% Rating 2 popup
uir2p = uicontrol('style','popup',...
           'String', 'No Ratings',...
           'Position', [311, 380, 90, 19],...
           'Fontsize', 8,...
           'Backgroundcolor', 'w',...
           'ForegroundColor', [0, 0.5, 0],...
           'Callback', @setrating2);
       
% Update Data pushbotton
uiudp = uicontrol('style','pushbutton',...
           'String', 'Update Data',...
           'Position', [74, 376, 106, 23],...
           'Fontsize', 8,...
           'Backgroundcolor', 'w',...
           'ForegroundColor', 'r',...
           'Callback', @update);
       
% Analysis pushbotton
uiap = uicontrol('style','pushbutton',...
           'String', 'Analysis',...
           'Position', [437, 395, 81, 23],...
           'Fontsize', 8,...
           'Backgroundcolor', 'w',...
           'Enable', 'off',...
           'Callback', @analysis);
       
% Axes
hax = axes('Units','pixels', 'position', [50, 50, 300, 300]);
plot(1, 1)
axis equal;

% analysis

% AUC 1 text
uicontrol('style','text',...
           'String', 'AUC 1 :',...
           'Position', [370, 333, 52, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% AUC 1 edit
uie1 = uicontrol('style','edit',...
           'String', 'AUC 1',...
           'Position', [430, 330, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'ForegroundColor', 'b',...
           'Backgroundcolor', 'w');

% AUC 2 text
uicontrol('style','text',...
           'String', 'AUC 2 :',...
           'Position', [370, 283, 52, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% AUC 2 edit
uie2 = uicontrol('style','edit',...
           'String', 'AUC 2',...
           'Position', [430, 280, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'ForegroundColor', [0, 0.5, 0],...
           'Backgroundcolor', 'w');

% VAR 1 text
uicontrol('style','text',...
           'String', 'VAR 1 :',...
           'Position', [370, 233, 52, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% VAR 1 edit
uie3 = uicontrol('style','edit',...
           'String', 'VAR 1',...
           'Position', [430, 230, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'ForegroundColor', 'b',...
           'Backgroundcolor', 'w');

% VAR 2 text
uicontrol('style','text',...
           'String', 'VAR 2 :',...
           'Position', [370, 183, 52, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% VAR 2 edit
uie4 = uicontrol('style','edit',...
           'String', 'VAR 2',...
           'Position', [430, 180, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'ForegroundColor', [0, 0.5, 0],...
           'BackgroundColor', 'w');

% COV12 text
uicontrol('style','text',...
           'String', 'COV12 :',...
           'Position', [370, 133, 56, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% COV12 edit
uie5 = uicontrol('style','edit',...
           'String', 'COV12',...
           'Position', [430, 130, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'BackgroundColor', 'w');

% TEST text
% uicontrol('style','text',...
%            'String', 'TEST : AUC 1 - AUC 2',...
%            'Position', [380, 90, 138, 15],...
%            'Fontsize', 10,...
%            'Backgroundcolor', 'w');

% p-value text
uicontrol('style','text',...
           'String', 'p-value :',...
           'Position', [370, 83, 56, 15],...
           'Fontsize', 10,...
           'Backgroundcolor', 'w');

% p-value edit
uie6 = uicontrol('style','edit',...
           'String', 'p-value',...
           'Position', [430, 80, 100, 22],...
           'Fontsize', 10,...
           'Enable', 'inactive',...
           'BackgroundColor', [0.93, 0.84, 0.84]);

%% Callback functions

    function clearAxes(hObj, event)
        fileIndex = get(uisfp, 'Value');
        filename = fileList{fileIndex};
        set(uiudp, 'ForegroundColor', 'r');
        set(uiap, 'Enable', 'off');
        set(uir1p, 'Value', 1);
        set(uir2p, 'Value', 1);
        set(uir1p, 'String', 'No Ratings');
        set(uir2p, 'String', 'No Ratings');
        cla;
    end

    function update(hObj, event)
        set(hObj, 'ForegroundColor', 'k');
        set(uiap, 'ForegroundColor', 'r');
        samples = loadsamples_(filename);
        [aucs, delongcov] = calroc_(samples);
        plotroc_(samples);
        set(uiap, 'Enable', 'on');
        k = numel(aucs);
        ratingList = getRatingList(k);
        set(uir1p, 'Value', 1);
        set(uir2p, 'Value', 1);
        rating1i = get(uir1p, 'Value');
        rating2i = get(uir2p, 'Value');
        set(uir1p, 'String', ratingList);
        set(uir2p, 'String', ratingList);
    end

    function analysis(hObj, event)
        set(uiudp, 'ForegroundColor', 'k');
        selectsamples.ratings = samples.ratings([rating1i, rating2i], :);
        selectsamples.spsizes = samples.spsizes;
        plotroc_(selectsamples);
        
        set(uie1, 'String', aucs(rating1i));
        set(uie2, 'String', aucs(rating2i));
        set(uie3, 'String', delongcov(rating1i, rating1i));
        set(uie4, 'String', delongcov(rating2i, rating2i));
        set(uie5, 'String', delongcov(rating1i, rating2i));
        
        pvalue = calpvalue_(aucs([rating1i, rating2i]), ...
            delongcov([rating1i, rating2i], [rating1i, rating2i]));
        if rating1i == rating2i
            pvalue = 1;
        end
        set(uie6, 'String', pvalue);
        
        if pvalue < 0.05
            set(uie6, 'BackgroundColor', [0.76, 0.87, 0.78]);
        else
            set(uie6, 'BackgroundColor', [0.93, 0.84, 0.84]);
        end
        
        set(uiap, 'ForegroundColor', 'k');
    end

    function setrating1(hObj, event)
        rating1i = get(hObj, 'Value');
        set(uiap, 'ForegroundColor', 'r');
    end

    function setrating2(hObj, event)
        rating2i = get(hObj, 'Value');
        set(uiap, 'ForegroundColor', 'r');
    end

%% Local functions

    function ratingList = getRatingList(ratingnum)
          ratingList = 1 : ratingnum;
    end

end