package com.example.accountmanager.service;

import com.example.accountmanager.entity.ZhanghaoInfo;
import com.example.accountmanager.repository.ZhanghaoInfoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

/**
 * 账号信息业务逻辑层
 */
@Service
public class ZhanghaoInfoService {

    private static final String COMPLETED_STATUS = "完成";

    @Autowired
    private ZhanghaoInfoRepository repository;

    /**
     * 获取所有未完成的账号
     */
    public List<ZhanghaoInfo> findAllActive() {
        return repository.findByStatusNot(COMPLETED_STATUS);
    }

    /**
     * 获取所有账号（包括已完成的）
     */
    public List<ZhanghaoInfo> findAll() {
        return repository.findAll();
    }

    /**
     * 根据ID获取账号
     */
    public Optional<ZhanghaoInfo> findById(Integer id) {
        return repository.findById(id);
    }

    /**
     * 创建账号
     */
    public ZhanghaoInfo create(ZhanghaoInfo info) {
        if (info.getDataTime() == null || info.getDataTime().isEmpty()) {
            info.setDataTime(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        return repository.save(info);
    }

    /**
     * 更新账号
     */
    public ZhanghaoInfo update(Integer id, ZhanghaoInfo info) {
        return repository.findById(id)
                .map(existing -> {
                    existing.setUserName(info.getUserName());
                    existing.setPassWord(info.getPassWord());
                    existing.setJingBi(info.getJingBi());
                    existing.setZhuanshi(info.getZhuanshi());
                    existing.setDataTime(info.getDataTime());
                    existing.setStatus(info.getStatus());
                    return repository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("账号不存在: " + id));
    }

    /**
     * 删除账号
     */
    public void delete(Integer id) {
        repository.deleteById(id);
    }

    /**
     * 按用户名搜索（排除已完成的）
     */
    public List<ZhanghaoInfo> searchByUserName(String userName) {
        return repository.findByUserNameContainingAndStatusNot(userName, COMPLETED_STATUS);
    }
}
