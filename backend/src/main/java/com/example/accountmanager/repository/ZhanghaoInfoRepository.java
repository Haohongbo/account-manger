package com.example.accountmanager.repository;

import com.example.accountmanager.entity.ZhanghaoInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 账号信息 Repository
 */
@Repository
public interface ZhanghaoInfoRepository extends JpaRepository<ZhanghaoInfo, Integer> {

    /**
     * 查找所有状态不等于指定值的账号
     */
    List<ZhanghaoInfo> findByStatusNot(String status);

    /**
     * 按用户名模糊搜索（排除已完成的账号）
     */
    List<ZhanghaoInfo> findByUserNameContainingAndStatusNot(String userName, String status);

    /**
     * 按用户名精确查找
     */
    List<ZhanghaoInfo> findByUserName(String userName);
}
