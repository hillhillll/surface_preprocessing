function PREPROC = humanfmri_r1_make_directories(subject_code, study_imaging_dir, func_tasks, varargin)

% The function creates directories for dicom files.
%
%
% :Usage:
% ::
%     PREPROC = humanfmri_r1_make_directories(subject_code, study_imaging_dir, varargin)
%
%
% :Input:
% ::
%   - subject_code       the subject code (e.g., 'sub-caps001').
%   - study_imaging_dir  the directory information for the study imaging data 
%                        (e.g., '/Volumes/habenula/hbmnas/data/CAPS2/Imaging').
%   - func_tasks         task names corresponding each data.
%                        (e.g., func_tasks = {'CAPS', 'QUIN', 'ODOR'})
%                        if some data are missing, just fill in blanks.
%                        (e.g., func_tasks = {'', 'QUIN', ''} <- only data 2!)
%
%
% :Optional Input:
% ::
%   - T2                 make in-plane T2 folder
%   - no_sbref           do not make SBRef folder
%   - no_fmap            do not make fieldmap folder
%   - fmap_enc_dir       fieldmap encoding directions
%                        default: {'ap', 'pa'}
%   - no_update          do not update PREPROC.mat file
%   - func_sess          session names corresponding each data.
%                        (e.g., func_sess = {'visit1', 'visit2', 'visit3'})
%                        runs without a specified func_task will be ignored.
%                        (default: [])
%   - func_runs          run number corresponding each data.
%                        (e.g., func_runs = [1 2 3], or [1 1 2 2])
%                        runs without a specified func_task will be ignored.
%                        (default: 1 .. #func_tasks)
%
%
% :Output:
% ::
%     PREPROC.study_imaging_dir
%     PREPROC.study_rawdata_dir
%     PREPROC.subject_code
%     PREPROC.subject_dir
%     PREPROC.dicom_anat_dir
%     PREPROC.dicom_func_bold_dir
%     PREPROC.dicom_func_sbref_dir
%     PREPROC.dicom_fmap_dir (if selected)
%
%
% :Example:
% ::
%
%
% ..
%     Author and copyright information:
%
%     Copyright (C) Jan 2019  Choong-Wan Woo & Jae-Joong Lee
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ..


fprintf('\n\n\n');
make_T2 = false;
make_sbref = true;
make_fmap = true;
fmap_enc_dir = {'ap', 'pa'};
do_update = true;
func_sess = [];
func_runs = 1:numel(func_tasks);

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'T2'}
                make_T2 = true;
            case {'no_sbref'}
                make_sbref = false;
            case {'no_fmap'}
                make_fmap = false;
            case {'fmap_enc_dir'}
                fmap_enc_dir = varargin{i+1};
            case {'no_update'}
                do_update = false;
            case {'func_sess'}
                func_sess = varargin{i+1};
            case {'func_runs'}
                func_runs = varargin{i+1};
        end
    end
end

subject_dir = fullfile(study_imaging_dir, 'raw', subject_code);
if do_update && exist(fullfile(subject_dir, 'PREPROC.mat')) == 2 % do update & mat file exist
    fprintf('Load existing PREPROC.mat and update it.\n');
    PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC
end

PREPROC.study_imaging_dir = study_imaging_dir;
PREPROC.study_rawdata_dir = fullfile(study_imaging_dir, 'raw');
PREPROC.subject_code = subject_code;
PREPROC.subject_dir = subject_dir;

print_header('Make directories for containing DICOM images', PREPROC.subject_code);

PREPROC.dicom_anat_dir{1, 1} = fullfile(PREPROC.subject_dir, 'dicom', 'anat', 'T1w');
system(['mkdir -p ' PREPROC.dicom_anat_dir{1}]);
if make_T2
    PREPROC.dicom_anat_dir{2, 1} = fullfile(PREPROC.subject_dir, 'dicom', 'anat', 'inplaneT2');
    system(['mkdir -p ' PREPROC.dicom_anat_dir{2}]);
end
for i = 1:numel(func_tasks)
    if ~isempty(func_tasks{i})
        if ~isempty(func_sess)
            funcprefix = sprintf('ses-%s_task-%s_run-%02d', func_sess{i}, func_tasks{i}, func_runs(i));
        else
            funcprefix = sprintf('task-%s_run-%02d', func_tasks{i}, func_runs(i));
        end
        PREPROC.dicom_func_bold_dir{i, 1} = fullfile(PREPROC.subject_dir, 'dicom', 'func', sprintf('%s_bold', funcprefix));
        system(['mkdir -p ' PREPROC.dicom_func_bold_dir{i}]);
        if make_sbref
            PREPROC.dicom_func_sbref_dir{i, 1} = fullfile(PREPROC.subject_dir, 'dicom', 'func', sprintf('%s_sbref', funcprefix));
            system(['mkdir -p ' PREPROC.dicom_func_sbref_dir{i}]);
        end
    end
end
if make_fmap
    for i = 1:numel(fmap_enc_dir)
        PREPROC.dicom_fmap_dir{i, 1} = fullfile(PREPROC.subject_dir, 'dicom', 'fmap', sprintf('dir-%s_epi', fmap_enc_dir{i}));
        system(['mkdir -p ' PREPROC.dicom_fmap_dir{i}]);
    end
end

save_load_PREPROC(PREPROC.subject_dir, 'save', PREPROC); % save PREPROC
fprintf('\n\n\n');

end