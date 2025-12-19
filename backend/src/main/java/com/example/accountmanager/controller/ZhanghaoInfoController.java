package com.example.accountmanager.controller;

import com.example.accountmanager.entity.ZhanghaoInfo;
import com.example.accountmanager.service.ZhanghaoInfoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 账号信息 RESTful API 控制器
 */
@RestController
@RequestMapping("/api/accounts")
@CrossOrigin(origins = "*")
public class ZhanghaoInfoController {

    @Autowired
    private ZhanghaoInfoService service;

    /**
     * 获取所有未完成的账号
     */
    @GetMapping
    public List<ZhanghaoInfo> getAllActive() {
        return service.findAllActive();
    }

    /**
     * 获取所有账号（包括已完成的）
     */
    @GetMapping("/all")
    public List<ZhanghaoInfo> getAll() {
        return service.findAll();
    }

    /**
     * 根据ID获取账号
     */
    @GetMapping("/{id}")
    public ResponseEntity<ZhanghaoInfo> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * 创建账号
     */
    @PostMapping
    public ZhanghaoInfo create(@RequestBody ZhanghaoInfo info) {
        return service.create(info);
    }

    /**
     * 更新账号
     */
    @PutMapping("/{id}")
    public ResponseEntity<ZhanghaoInfo> update(@PathVariable Integer id, @RequestBody ZhanghaoInfo info) {
        try {
            return ResponseEntity.ok(service.update(id, info));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * 删除账号
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * 按用户名搜索
     */
    @GetMapping("/search")
    public List<ZhanghaoInfo> search(@RequestParam String userName) {
        return service.searchByUserName(userName);
    }
}
