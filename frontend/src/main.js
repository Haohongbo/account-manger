/**
 * 账号管理系统 - 主逻辑
 */

// 默认 API 配置
const DEFAULT_API_URL = 'http://localhost:8080/api/accounts';
const STORAGE_KEY_API_URL = 'account_manager_api_url';

// 从本地存储加载 API 地址
function getApiUrl() {
    return localStorage.getItem(STORAGE_KEY_API_URL) || DEFAULT_API_URL;
}

// 保存 API 地址到本地存储
function saveApiUrl(url) {
    localStorage.setItem(STORAGE_KEY_API_URL, url);
}

// 状态管理
let accounts = [];
let filteredAccounts = [];
let currentEditId = null;
let deleteTargetId = null;

// DOM 元素
const elements = {
    // 导航
    navItems: document.querySelectorAll('.nav-item'),

    // 页面
    listPage: document.getElementById('listPage'),
    formPage: document.getElementById('formPage'),
    settingsPage: document.getElementById('settingsPage'),

    // 列表页
    accountTableBody: document.getElementById('accountTableBody'),
    accountCount: document.getElementById('accountCount'),
    emptyState: document.getElementById('emptyState'),

    // 高级搜索
    searchUserName: document.getElementById('searchUserName'),
    jingBiMin: document.getElementById('jingBiMin'),
    jingBiMax: document.getElementById('jingBiMax'),
    zhuanshiMin: document.getElementById('zhuanshiMin'),
    zhuanshiMax: document.getElementById('zhuanshiMax'),
    vipMin: document.getElementById('vipMin'),
    vipMax: document.getElementById('vipMax'),
    phoneTail: document.getElementById('phoneTail'),
    phoneEmpty: document.getElementById('phoneEmpty'),
    advSearchBtn: document.getElementById('advSearchBtn'),
    resetBtn: document.getElementById('resetBtn'),
    refreshBtn: document.getElementById('refreshBtn'),

    // 表单页
    formTitle: document.getElementById('formTitle'),
    accountForm: document.getElementById('accountForm'),
    formId: document.getElementById('formId'),
    formUserName: document.getElementById('formUserName'),
    formPassWord: document.getElementById('formPassWord'),
    formJingBi: document.getElementById('formJingBi'),
    formZhuanshi: document.getElementById('formZhuanshi'),
    formStatus: document.getElementById('formStatus'),
    cancelBtn: document.getElementById('cancelBtn'),

    // 设置页
    apiUrlInput: document.getElementById('apiUrlInput'),
    connectionStatus: document.getElementById('connectionStatus'),
    testConnectionBtn: document.getElementById('testConnectionBtn'),
    saveSettingsBtn: document.getElementById('saveSettingsBtn'),
    resetDefaultBtn: document.getElementById('resetDefaultBtn'),

    // 模态框
    deleteModal: document.getElementById('deleteModal'),
    cancelDeleteBtn: document.getElementById('cancelDeleteBtn'),
    confirmDeleteBtn: document.getElementById('confirmDeleteBtn'),

    // Toast
    toast: document.getElementById('toast'),
};

// =====================================
// API 调用
// =====================================
const api = {
    async getAll() {
        const response = await fetch(getApiUrl());
        if (!response.ok) throw new Error('获取数据失败');
        return response.json();
    },

    async getById(id) {
        const response = await fetch(`${getApiUrl()}/${id}`);
        if (!response.ok) throw new Error('获取数据失败');
        return response.json();
    },

    async create(data) {
        const response = await fetch(getApiUrl(), {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data),
        });
        if (!response.ok) throw new Error('创建失败');
        return response.json();
    },

    async update(id, data) {
        const response = await fetch(`${getApiUrl()}/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data),
        });
        if (!response.ok) throw new Error('更新失败');
        return response.json();
    },

    async delete(id) {
        const response = await fetch(`${getApiUrl()}/${id}`, {
            method: 'DELETE',
        });
        if (!response.ok) throw new Error('删除失败');
    },

    async testConnection(url) {
        const response = await fetch(url, { method: 'GET' });
        return response.ok;
    }
};

// =====================================
// 工具函数
// =====================================

// 从状态字段解析 VIP 等级
function parseVipLevel(status) {
    if (!status) return null;
    const match = status.match(/vip[等级]*\s*(\d+)/i);
    return match ? parseInt(match[1]) : null;
}

// 从状态字段解析手机尾号
function parsePhoneTail(status) {
    if (!status) return null;
    const match = status.match(/[手机尾号：:]+\s*(\d+)/);
    return match ? match[1] : null;
}

// 解析金币数值（单位：亿）
function parseJingBi(value) {
    if (!value) return 0;
    const num = parseFloat(value.replace(/[^\d.-]/g, ''));
    return isNaN(num) ? 0 : num;
}

// 解析钻石数值（单位：万）
function parseZhuanshi(value) {
    if (!value) return 0;
    const num = parseFloat(value.replace(/[^\d.-]/g, ''));
    return isNaN(num) ? 0 : num;
}

// 复制到剪贴板
async function copyToClipboard(text, buttonId) {
    try {
        await navigator.clipboard.writeText(text);
        const btn = document.getElementById(buttonId);
        if (btn) {
            btn.classList.add('copied');
            btn.textContent = '已复制';
            setTimeout(() => {
                btn.classList.remove('copied');
                btn.textContent = btn.dataset.originalText;
            }, 1500);
        }
        showToast('复制成功', 'success');
    } catch (err) {
        showToast('复制失败', 'error');
    }
}

// =====================================
// UI 更新
// =====================================

// 显示 Toast 提示
function showToast(message, type = 'info') {
    elements.toast.textContent = message;
    elements.toast.className = `toast ${type} show`;

    setTimeout(() => {
        elements.toast.classList.remove('show');
    }, 3000);
}

// 切换页面
function switchPage(pageName) {
    elements.navItems.forEach(item => {
        item.classList.toggle('active', item.dataset.page === pageName);
    });

    // 隐藏所有页面
    elements.listPage.classList.remove('active');
    elements.formPage.classList.remove('active');
    elements.settingsPage.classList.remove('active');

    if (pageName === 'list') {
        elements.listPage.classList.add('active');
    } else if (pageName === 'add') {
        elements.formPage.classList.add('active');
        resetForm();
        elements.formTitle.textContent = '添加账号';
    } else if (pageName === 'settings') {
        elements.settingsPage.classList.add('active');
        // 加载当前API地址
        elements.apiUrlInput.value = getApiUrl();
    }
}

// 重置表单
function resetForm() {
    elements.accountForm.reset();
    elements.formId.value = '';
    currentEditId = null;
}

// 重置搜索条件
function resetSearchFilters() {
    elements.searchUserName.value = '';
    elements.jingBiMin.value = '';
    elements.jingBiMax.value = '';
    elements.zhuanshiMin.value = '';
    elements.zhuanshiMax.value = '';
    elements.vipMin.value = '';
    elements.vipMax.value = '';
    elements.phoneTail.value = '';
    elements.phoneEmpty.checked = false;
}

// 更新连接状态显示
function updateConnectionStatus(status, text) {
    elements.connectionStatus.className = `connection-status ${status}`;
    elements.connectionStatus.querySelector('.status-text').textContent = text;
}

// 渲染账号列表
function renderAccountList(data) {
    filteredAccounts = data;

    if (filteredAccounts.length === 0) {
        elements.accountTableBody.innerHTML = '';
        elements.emptyState.style.display = 'block';
        elements.accountCount.textContent = '0 个账号';
        return;
    }

    elements.emptyState.style.display = 'none';
    elements.accountCount.textContent = `${filteredAccounts.length} 个账号`;

    elements.accountTableBody.innerHTML = filteredAccounts.map(account => `
        <tr class="slide-up">
            <td>${account.id || '-'}</td>
            <td><strong>${escapeHtml(account.userName || '-')}</strong></td>
            <td>${escapeHtml(account.passWord || '-')}</td>
            <td>${escapeHtml(account.jingBi || '0')}</td>
            <td>${escapeHtml(account.zhuanshi || '0')}</td>
            <td>${escapeHtml(account.dataTime || '-')}</td>
            <td>
                <span class="status-badge status-${account.status || ''}">
                    ${escapeHtml(account.status || '未知')}
                </span>
            </td>
            <td>
                <div class="action-btns">
                    <div class="copy-btns">
                        <button id="copyU${account.id}" class="btn-copy" data-original-text="用户名" 
                            onclick="copyToClipboard('${escapeHtml(account.userName || '')}', 'copyU${account.id}')">
                            用户名
                        </button>
                        <button id="copyP${account.id}" class="btn-copy" data-original-text="密码"
                            onclick="copyToClipboard('${escapeHtml(account.passWord || '')}', 'copyP${account.id}')">
                            密码
                        </button>
                        <button id="copyB${account.id}" class="btn-copy" data-original-text="账密"
                            onclick="copyToClipboard('${escapeHtml(account.userName || '')}----${escapeHtml(account.passWord || '')}', 'copyB${account.id}')">
                            账密
                        </button>
                    </div>
                    <button class="btn btn-secondary btn-sm" onclick="editAccount(${account.id})">
                        ✏️ 编辑
                    </button>
                    <button class="btn btn-danger btn-sm" onclick="confirmDelete(${account.id})">
                        🗑️ 删除
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

// HTML 转义
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// =====================================
// 搜索过滤
// =====================================

// 应用搜索过滤
function applyFilters() {
    const filters = {
        userName: elements.searchUserName.value.trim().toLowerCase(),
        jingBiMin: parseFloat(elements.jingBiMin.value) || null,
        jingBiMax: parseFloat(elements.jingBiMax.value) || null,
        zhuanshiMin: parseFloat(elements.zhuanshiMin.value) || null,
        zhuanshiMax: parseFloat(elements.zhuanshiMax.value) || null,
        vipMin: parseInt(elements.vipMin.value) || null,
        vipMax: parseInt(elements.vipMax.value) || null,
        phoneTail: elements.phoneTail.value.trim(),
        phoneEmpty: elements.phoneEmpty.checked,
    };

    const filtered = accounts.filter(account => {
        // 用户名过滤
        if (filters.userName && (!account.userName ||
            !account.userName.toLowerCase().includes(filters.userName))) {
            return false;
        }

        // 金币范围过滤（单位：亿）
        const jingBi = parseJingBi(account.jingBi);
        if (filters.jingBiMin !== null && jingBi < filters.jingBiMin) {
            return false;
        }
        if (filters.jingBiMax !== null && jingBi > filters.jingBiMax) {
            return false;
        }

        // 钻石范围过滤（单位：万）
        const zhuanshi = parseZhuanshi(account.zhuanshi);
        if (filters.zhuanshiMin !== null && zhuanshi < filters.zhuanshiMin) {
            return false;
        }
        if (filters.zhuanshiMax !== null && zhuanshi > filters.zhuanshiMax) {
            return false;
        }

        // VIP等级过滤
        const vipLevel = parseVipLevel(account.status);
        if (filters.vipMin !== null || filters.vipMax !== null) {
            if (vipLevel === null) return false;
            if (filters.vipMin !== null && vipLevel < filters.vipMin) return false;
            if (filters.vipMax !== null && vipLevel > filters.vipMax) return false;
        }

        // 手机尾号过滤
        const phoneTail = parsePhoneTail(account.status);
        if (filters.phoneEmpty) {
            // 搜索空尾号
            if (phoneTail !== null) return false;
        } else if (filters.phoneTail) {
            // 搜索特定尾号
            if (!phoneTail || !phoneTail.includes(filters.phoneTail)) return false;
        }

        return true;
    });

    renderAccountList(filtered);
}

// =====================================
// 数据操作
// =====================================

// 加载账号列表
async function loadAccounts() {
    try {
        accounts = await api.getAll();
        renderAccountList(accounts);
    } catch (error) {
        console.error('加载账号失败:', error);
        showToast('加载账号失败，请检查后端服务是否启动', 'error');
    }
}

// 编辑账号 - 从本地缓存data中查找，避免再次请求API
async function editAccount(id) {
    try {
        // 优先从已加载的账号列表中查找
        let account = accounts.find(a => a.id === id);

        // 如果本地没有找到，则从API获取
        if (!account) {
            account = await api.getById(id);
        }

        if (!account) {
            showToast('账号不存在', 'error');
            return;
        }

        currentEditId = id;
        elements.formId.value = id;
        elements.formUserName.value = account.userName || '';
        elements.formPassWord.value = account.passWord || '';
        elements.formJingBi.value = account.jingBi || '';
        elements.formZhuanshi.value = account.zhuanshi || '';
        elements.formStatus.value = account.status || '';

        elements.formTitle.textContent = '编辑账号';

        // 切换页面
        elements.navItems.forEach(item => {
            item.classList.toggle('active', item.dataset.page === 'add');
        });
        elements.listPage.classList.remove('active');
        elements.settingsPage.classList.remove('active');
        elements.formPage.classList.add('active');

    } catch (error) {
        console.error('获取账号详情失败:', error);
        showToast('获取账号详情失败', 'error');
    }
}

// 保存账号
async function saveAccount(event) {
    event.preventDefault();

    const data = {
        userName: elements.formUserName.value.trim(),
        passWord: elements.formPassWord.value.trim(),
        jingBi: elements.formJingBi.value.trim() || '0',
        zhuanshi: elements.formZhuanshi.value.trim() || '0',
        status: elements.formStatus.value.trim(),
    };

    if (!data.userName) {
        showToast('请输入用户名', 'error');
        return;
    }

    try {
        if (currentEditId) {
            await api.update(currentEditId, data);
            showToast('账号更新成功', 'success');
        } else {
            await api.create(data);
            showToast('账号创建成功', 'success');
        }

        switchPage('list');
        loadAccounts();
    } catch (error) {
        console.error('保存失败:', error);
        showToast('保存失败', 'error');
    }
}

// 确认删除
function confirmDelete(id) {
    deleteTargetId = id;
    elements.deleteModal.classList.add('active');
}

// 执行删除
async function executeDelete() {
    if (!deleteTargetId) return;

    try {
        await api.delete(deleteTargetId);
        showToast('删除成功', 'success');
        elements.deleteModal.classList.remove('active');
        loadAccounts();
    } catch (error) {
        console.error('删除失败:', error);
        showToast('删除失败', 'error');
    } finally {
        deleteTargetId = null;
    }
}

// =====================================
// 设置功能
// =====================================

// 测试连接
async function testConnection() {
    const url = elements.apiUrlInput.value.trim();
    if (!url) {
        showToast('请输入接口地址', 'error');
        return;
    }

    updateConnectionStatus('testing', '正在测试...');

    try {
        const success = await api.testConnection(url);
        if (success) {
            updateConnectionStatus('connected', '连接成功');
            showToast('连接测试成功', 'success');
        } else {
            updateConnectionStatus('disconnected', '连接失败');
            showToast('连接测试失败', 'error');
        }
    } catch (error) {
        updateConnectionStatus('disconnected', '连接失败: ' + error.message);
        showToast('连接测试失败', 'error');
    }
}

// 保存设置
function saveSettings() {
    const url = elements.apiUrlInput.value.trim();
    if (!url) {
        showToast('请输入接口地址', 'error');
        return;
    }

    saveApiUrl(url);
    showToast('设置已保存', 'success');

    // 重新加载数据
    loadAccounts();
}

// 恢复默认设置
function resetToDefault() {
    localStorage.removeItem(STORAGE_KEY_API_URL);
    elements.apiUrlInput.value = DEFAULT_API_URL;
    updateConnectionStatus('', '未检测');
    showToast('已恢复默认设置', 'success');
    loadAccounts();
}

// =====================================
// 事件绑定
// =====================================
function initEventListeners() {
    // 导航点击
    elements.navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            switchPage(item.dataset.page);
        });
    });

    // 刷新按钮
    elements.refreshBtn.addEventListener('click', loadAccounts);

    // 高级搜索
    elements.advSearchBtn.addEventListener('click', applyFilters);

    // 重置按钮
    elements.resetBtn.addEventListener('click', () => {
        resetSearchFilters();
        loadAccounts();
    });

    // 回车搜索
    [elements.searchUserName, elements.jingBiMin, elements.jingBiMax,
    elements.zhuanshiMin, elements.zhuanshiMax, elements.vipMin,
    elements.vipMax, elements.phoneTail].forEach(input => {
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') applyFilters();
        });
    });

    // 表单提交
    elements.accountForm.addEventListener('submit', saveAccount);

    // 取消按钮
    elements.cancelBtn.addEventListener('click', () => {
        switchPage('list');
    });

    // 设置页面
    elements.testConnectionBtn.addEventListener('click', testConnection);
    elements.saveSettingsBtn.addEventListener('click', saveSettings);
    elements.resetDefaultBtn.addEventListener('click', resetToDefault);

    // API地址输入框失焦自动保存
    elements.apiUrlInput.addEventListener('blur', () => {
        const url = elements.apiUrlInput.value.trim();
        if (url) {
            saveApiUrl(url);
        }
    });

    // 删除模态框
    elements.cancelDeleteBtn.addEventListener('click', () => {
        elements.deleteModal.classList.remove('active');
        deleteTargetId = null;
    });
    elements.confirmDeleteBtn.addEventListener('click', executeDelete);

    // 点击模态框外部关闭
    elements.deleteModal.addEventListener('click', (e) => {
        if (e.target === elements.deleteModal) {
            elements.deleteModal.classList.remove('active');
            deleteTargetId = null;
        }
    });
}

// 暴露全局函数供 onclick 使用
window.editAccount = editAccount;
window.confirmDelete = confirmDelete;
window.copyToClipboard = copyToClipboard;

// =====================================
// 初始化
// =====================================
document.addEventListener('DOMContentLoaded', () => {
    initEventListeners();

    // 加载保存的API地址到设置页
    elements.apiUrlInput.value = getApiUrl();

    // 加载账号数据
    loadAccounts();
});
